[![Build Status](https://travis-ci.com/drew2a/wireguard.svg?branch=master)](https://travis-ci.com/drew2a/wireguard)
[![Maintainability](https://api.codeclimate.com/v1/badges/2092ead49a2e82b38f64/maintainability)](https://codeclimate.com/github/drew2a/wireguard/maintainability)

# Wireguard

This repository contains scripts that make it easy to configure [WireGuard](https://www.wireguard.com)
on [VPS](https://en.wikipedia.org/wiki/Virtual_private_server).

Medium article: [How to deploy WireGuard node on a DigitalOcean's droplet](https://medium.com/@drew2a/replace-your-vpn-provider-by-setting-up-wireguard-on-digitalocean-6954c9279b17)

## Quick Start

### Ubuntu

```bash
wget https://raw.githubusercontent.com/drew2a/wireguard/master/wg-ubuntu-server-up.sh

chmod +x ./wg-ubuntu-server-up.sh
sudo ./wg-ubuntu-server-up.sh
```


### Debian

```bash
wget https://raw.githubusercontent.com/drew2a/wireguard/master/wg-debian-server-up.sh

chmod +x ./wg-debian-server-up.sh
sudo ./wg-debian-server-up.sh
```


To get a full instruction, please follow to the article above.

### Supported OS

* Ubuntu 18.04
* Ubuntu 20.04
* Debian 9
* Debian 10

## wg-ubuntu-server-up.sh

This script:

* Installs all necessary software on an empty Ubuntu DigitalOcean droplet
(it should also work with most modern Ubuntu images)
* Configures IPv4 forwarding and iptables rules
* Sets up [unbound](https://github.com/NLnetLabs/unbound) DNS resolver 
* Creates a server and clients configurations
* Installs [qrencode](https://github.com/fukuchi/libqrencode/)
* Runs [WireGuard](https://www.wireguard.com)


### Usage

```bash
wg-ubuntu-server-up.sh [--clients=<clients_count>] [--cidr=<cidr_address>] [--listen-port=<listen_port>] [--dns=<dns_ip>] [--no-reboot] [--no-unbound]
```

Options:

* `--clients=<clients_count>` how many client configs will be generated (10 as default)
* `--cidr=<cidr_address>` the cidr network range for the new wireguard network (10.0.0.0/24 as default)
* `--dns=<dns_ip>` DNS server address (uses wireguard ip address as default, if --no-unbound is selected 1.1.1.1 is chosen)
* `--listen-port=<listen_port>` the port wireguard listens on (51820 as default)
* `--no-unbound` disables Unbound server installation (1.1.1.1 will be used as
   a default DNS for client's configs)
* `--no-reboot` disables rebooting at the end of the script execution

### Example of usage

```bash
./wg-ubuntu-server-up.sh
```

```bash
./wg-ubuntu-server-up.sh --clients=10
```

## wg-debian-server-up.sh

This script works the same way and with the same options, that
`wg-ubuntu-server-up.sh` do.

## wg-genconf.sh

This script generate server and clients configs for WireGuard.

If the public IP is not defined, then the public IP of the machine from which 
the script is run is used.
If the number of clients is not defined, then used 10 clients.

### Prerequisites

Install [WireGuard](https://www.wireguard.com) if it's not installed.

### Usage

```bash
./wg-genconf.sh  [--clients=<clients_count>] [--cidr=<cidr_address>] [--dns=<dns_ip>] [--server-ip=<server_ip>] [--listen-port=<listen_port>]
```

Where:

* `clients` how many client configs will be generated (10 as default)
* `cidr` the cidr network range for the new wireguard network (10.0.0.0/24 as default)
* `dns` the script should use this IP as a DNS address (uses wireguard ip address as default)
* `server-ip` the script should use this IP as a server address (host address as default)
* `listen-port` the port wireguard listens on (51820 as default)


### Example of usage:

```bash
./wg-genconf.sh
```

```bash
./wg-genconf.sh --clients=10
```

```bash
./wg-genconf.sh --clients=10 --cidr=10.0.0.0/24
```

```bash
./wg-genconf.sh --dns=1.1.1.1 --server-ip=157.245.73.253
```

```bash
./wg-genconf.sh --clients=10 --cidr=10.0.0.0/24 --dns=1.1.1.1 --server-ip=157.245.73.253 --listen-port=51821
```
