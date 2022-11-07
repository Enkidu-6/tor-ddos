#!/bin/bash
# set -x
iptables-save > /var/tmp/iptablesRules-pre-update.v4
ip6tables-save > /var/tmp/ip6tablesRules-pre-update.v4
ipset save -f /var/tmp/ipset.full
iptables -Z
iptables -t mangle -F
ip6tables -Z
ip6tables -t mangle -F
sleep 1
ipset destroy
sysctl net.ipv4.ip_local_port_range="10000 65000"
echo 20 > /proc/sys/net/ipv4/tcp_fin_timeout
modprobe xt_recent ip_list_tot=10000
ipset restore -exist -f /var/tmp/ipset.full
sleep 1
# Change this number to your own ORPort if it's not 443
ORPort=443
iptables -t mangle -I PREROUTING -p tcp -m set --match-set allow-list src -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -m recent --name tor-ddos --set
iptables -t mangle -A PREROUTING -p tcp --syn --dport $ORPort -m conntrack --ctstate NEW -m hashlimit --hashlimit-name TOR --hashlimit-mode srcip --hashlimit-srcmask 32 --hashlimit-above 3/sec --hashlimit-burst 4 --hashlimit-htable-expire 3500 -j SET --add-set persec src
iptables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -m connlimit --connlimit-mask 32 --connlimit-above 4 -j SET --add-set tor-ddos src
iptables -t mangle -A PREROUTING -p tcp --syn --destination-port $ORPort -m connlimit --connlimit-mask 32 --connlimit-above 4 -j DROP
iptables -t mangle -A PREROUTING -p tcp -m set --match-set persec src -j DROP
iptables -t mangle -A PREROUTING -p tcp -m set --match-set tor-ddos src -j DROP
iptables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -j ACCEPT
ip6tables -t mangle -I PREROUTING -p tcp -m set --match-set allow-list6 src -j ACCEPT
ip6tables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -m recent --name tor-ddos6 --set
ip6tables -t mangle -A PREROUTING -p tcp --syn --dport $ORPort -m conntrack --ctstate NEW -m hashlimit --hashlimit-name TOR6 --hashlimit-mode srcip --hashlimit-srcmask 128 --hashlimit-above 2/sec --hashlimit-burst 3 --hashlimit-htable-expire 3600 -j SET --add-set persec6 src
ip6tables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -m connlimit --connlimit-mask 128 --connlimit-above 4 -j SET --add-set tor-ddos6 src
ip6tables -t mangle -A PREROUTING -p tcp --syn --destination-port $ORPort -m connlimit --connlimit-mask 128 --connlimit-above 4 -j DROP
ip6tables -t mangle -A PREROUTING -p tcp -m set --match-set persec6 src -j DROP
ip6tables -t mangle -A PREROUTING -p tcp -m set --match-set tor-ddos6 src -j DROP
ip6tables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -j ACCEPT
