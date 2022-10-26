#!/bin/bash
# set -x
iptables-save > /var/tmp/iptablesRules.v4
iptables -t mangle -F
sysctl net.ipv4.ip_local_port_range="10000 65000"
echo 20 > /proc/sys/net/ipv4/tcp_fin_timeout
modprobe xt_recent ip_list_tot=10000
# Change this number to your own ORPort if it's not 443
ORPort=443
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
ipset create persec hash:ip family inet hashsize 4096 timeout 3600
iptables -t mangle -I PREROUTING -p tcp -m set --match-set allow-list src -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -m recent --name tor-ddos --set
iptables -t mangle -A PREROUTING -p tcp --syn --dport $ORPort -m conntrack --ctstate NEW -m hashlimit --hashlimit-name TOR --hashlimit-mode srcip --hashlimit-srcmask 32 --hashlimit-above 3/sec --hashlimit-burst 4 --hashlimit-htable-expire 3500 -j SET --add-set persec src
iptables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -m connlimit --connlimit-mask 32 --connlimit-above 2 -j SET --add-set tor-ddos src
iptables -t mangle -A PREROUTING -p tcp --syn --destination-port $ORPort -m connlimit --connlimit-mask 32 --connlimit-above 2 -j DROP
iptables -t mangle -A PREROUTING -p tcp -m set --match-set persec src -j DROP
iptables -t mangle -A PREROUTING -p tcp -m set --match-set tor-ddos src -j DROP
iptables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -j ACCEPT
