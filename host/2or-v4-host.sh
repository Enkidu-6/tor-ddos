#!/bin/bash
# set -x
iptables-save > /var/tmp/iptablesRules.v4
sysctl net.ipv4.ip_local_port_range="10000 65000"
echo 20 > /proc/sys/net/ipv4/tcp_fin_timeout
modprobe xt_recent ip_list_tot=10000
# Change this to the IP address of your VM
ipaddress=10.1.1.2
# Change this number to your own ORPort if it's not 443
ORPort=443
# Change this number to your second ORPort if it's not 80
ORPort2=80
ipset create -exist allow-list hash:ip
ipset add -exist allow-list 128.31.0.34
ipset add -exist allow-list 131.188.40.189
ipset add -exist allow-list 154.35.175.225
ipset add -exist allow-list 171.25.193.9
ipset add -exist allow-list 193.23.244.244
ipset add -exist allow-list 199.58.81.140
ipset add -exist allow-list 204.13.164.118
ipset add -exist allow-list 45.66.33.45
ipset add -exist allow-list 66.111.2.131
ipset add -exist allow-list 86.59.21.38
ipset add -exist allow-list 193.187.88.42
ipset create tor-ddos hash:ip family inet hashsize 4096 timeout 43200
ipset create tor2-ddos hash:ip family inet hashsize 4096 timeout 43200
iptables -t mangle -I PREROUTING -p tcp -m set --match-set allow-list src -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp --syn --destination $ipaddress --destination-port $ORPort -m hashlimit --hashlimit-name TOR-$ORPort --hashlimit-mode srcip --hashlimit-srcmask 32 --hashlimit-above 1/minute --hashlimit-burst 5 --hashlimit-htable-expire 60000 -j DROP
iptables -t mangle -A PREROUTING -p tcp --syn --destination $ipaddress --destination-port $ORPort2 -m hashlimit --hashlimit-name TOR-$ORPort2 --hashlimit-mode srcip --hashlimit-srcmask 32 --hashlimit-above 1/minute --hashlimit-burst 5 --hashlimit-htable-expire 60000 -j DROP
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort -m recent --name tor-ddos --set
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort2 -m recent --name tor2-ddos --set
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort -m connlimit --connlimit-mask 32 --connlimit-above 4 -j SET --add-set tor-ddos src
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort2 -m connlimit --connlimit-mask 32 --connlimit-above 4 -j SET --add-set tor2-ddos src
iptables -t mangle -A PREROUTING -p tcp --syn --destination $ipaddress --destination-port $ORPort -m connlimit --connlimit-mask 32 --connlimit-above 4 -j DROP
iptables -t mangle -A PREROUTING -p tcp --syn --destination $ipaddress --destination-port $ORPort2 -m connlimit --connlimit-mask 32 --connlimit-above 4 -j DROP
iptables -t mangle -A PREROUTING -p tcp -m set --match-set tor-ddos src -j DROP
iptables -t mangle -A PREROUTING -p tcp -m set --match-set tor2-ddos src -j DROP
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort2 -j ACCEPT
