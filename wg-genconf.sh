#!/usr/bin/env bash
# usage:
#     wg-genconf.sh [--clients=<clients_count>] [--cidr=<cidr_address>] [--dns=<dns_ip>] [--server-ip=<server_ip>] [--listen-port=<listen_port>]

set -e # exit when any command fails
set -x # enable print all commands


# default wireguard network cidr
ip1=10
ip2=0
ip3=0
ip4=0
ip="${ip1}.${ip2}.${ip3}.${ip4}" # default ip

cidr=24
cidr_address="${ip}/${cidr}"

# default wireguard ip address
wireguard_instance_ip="$ip1.$ip2.$ip3.$((ip4+1))"

# default client count
clients_count=10

listen_port=51820

dns_ip=""
server_ip=""

for arg in "$@"
do
  [[ "${arg}" == "--server-ip="* ]] && server_ip=${arg#*=}
  [[ "${arg}" == "--dns="* ]] && dns_ip=${arg#*=}
  [[ "${arg}" == "--clients="* ]] && clients_count=${arg#*=}
  [[ "${arg}" == "--listen-port="* ]] && listen_port=${arg#*=}
  [[ "${arg}" == "--cidr="* ]] && cidr_address=${arg#*=}
done

# do some basic check on cidr address
cidr_regex="^([0-9]{1,3}\.){3}[0-9]{1,3}(\/([0-9]|[1-2][0-9]|3[0-2]))?$"

if [[ $cidr_address =~ $cidr_regex ]]; then
  IFS="./" read -r ip1 ip2 ip3 ip4 N <<< "${cidr_address}"
  ip_calc=$((ip1 * 256 ** 3 + ip2 * 256 ** 2 + ip3 * 256 + ip4))
  if [ $((ip_calc % 2**(32-N))) = 0 ]; then
    cidr=$N
    ip="${ip1}.${ip2}.${ip3}.${ip4}"
    wireguard_instance_ip="${ip1}.${ip2}.${ip3}.$((ip4+1))"
  else
    echo "Invalid cidr. defaulting to ${ip}/${cidr}"
  fi
fi


if [ -z "$dns_ip" ]; then # set dns server to the same as hostname if not found
  dns_ip=wireguard_instance_ip
fi

if [ -z "$server_ip" ]; then
  server_ip=$(hostname -I | awk '{print $1;}') # get only first hostname
fi




server_private_key=$(wg genkey)
server_public_key=$(echo "${server_private_key}" | wg pubkey)
server_config=wg0.conf

# The older code was directly referencing eth0 as the public interface in PostUp&PostDown events.
# Let's find that interface's name dynamic.
# If you have a different configuration just uncomment and edit the following line and comment the next.
#
#server_public_interface=eth0
#
#   thanks https://github.com/buraksarica for this improvement.
server_public_interface=$(route -n | awk '$1 == "0.0.0.0" {print $8}')

echo Generate server \("${server_ip}"\) config:
echo
echo -e "\t$(pwd)/${server_config}"
#
# server configs
#
cat > "${server_config}" <<EOL
[Interface]
Address = ${wireguard_instance_ip}/${cidr}
SaveConfig = true
ListenPort = ${listen_port}
PrivateKey = ${server_private_key}
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ${server_public_interface} -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ${server_public_interface} -j MASQUERADE
EOL

echo
echo Generate configs for "${clients_count}" clients:
echo
#
# clients configs
#
for i in $(seq 1 "${clients_count}");
do
    client_private_key=$(wg genkey)
    client_public_key=$(echo "${client_private_key}" | wg pubkey)
    client_ip="${ip1}.${ip2}.${ip3}.$((i+1+ip4))/${cidr}"
    client_config=client$i.conf
    echo -e "\t$(pwd)/${client_config}"
  	cat > "${client_config}" <<EOL
[Interface]
PrivateKey = ${client_private_key}
ListenPort = ${listen_port}
Address = ${client_ip}
DNS = ${dns_ip}

[Peer]
PublicKey = ${server_public_key}
AllowedIPs = 0.0.0.0/0
Endpoint = ${server_ip}:${listen_port}
PersistentKeepalive = 21
EOL
    cat >> "${server_config}" <<EOL
[Peer]
PublicKey = ${client_public_key}
AllowedIPs = ${client_ip}
EOL
done
