#!/bin/bash
# set -x
iptables-save > /var/tmp/iptablesRules-pre-update.v4
iptables-save > /var/tmp/ip6tablesRules-pre-update.v4
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
# Change this to the IP address of your VM
ipaddress=10.1.1.2
# Change this to the IPv6 address of your VM
ip6address=xxxx:xxxx::xxxx
# Change this number to your own ORPort if it's not 443
ORPort=443
# Change this number to your second ORPort if it's not 80
ORPort2=80
iptables -t mangle -I PREROUTING -p tcp -m set --match-set allow-list src -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort -m recent --name tor-ddos --set
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort2 -m recent --name tor2-ddos --set
iptables -t mangle -A PREROUTING -p tcp --syn --destination $ipaddress --dport $ORPort -m conntrack --ctstate NEW -m hashlimit --hashlimit-name TOR --hashlimit-mode srcip --hashlimit-srcmask 32 --hashlimit-above 3/sec --hashlimit-burst 4 --hashlimit-htable-expire 3500 -j SET --add-set persec src
iptables -t mangle -A PREROUTING -p tcp --syn --destination $ipaddress --dport $ORPort2 -m conntrack --ctstate NEW -m hashlimit --hashlimit-name TOR2 --hashlimit-mode srcip --hashlimit-srcmask 32 --hashlimit-above 3/sec --hashlimit-burst 4 --hashlimit-htable-expire 3500 -j SET --add-set persec2 src
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort -m connlimit --connlimit-mask 32 --connlimit-above 4 -j SET --add-set tor-ddos src
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort2 -m connlimit --connlimit-mask 32 --connlimit-above 4 -j SET --add-set tor2-ddos src
iptables -t mangle -A PREROUTING -p tcp --syn --destination $ipaddress --destination-port $ORPort -m connlimit --connlimit-mask 32 --connlimit-above 4 -j DROP
iptables -t mangle -A PREROUTING -p tcp --syn --destination $ipaddress --destination-port $ORPort2 -m connlimit --connlimit-mask 32 --connlimit-above 4 -j DROP
iptables -t mangle -A PREROUTING -p tcp -m set --match-set persec src -j DROP
iptables -t mangle -A PREROUTING -p tcp -m set --match-set persec2 src -j DROP
iptables -t mangle -A PREROUTING -p tcp -m set --match-set tor-ddos src -j DROP
iptables -t mangle -A PREROUTING -p tcp -m set --match-set tor2-ddos src -j DROP
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort2 -j ACCEPT
ip6tables -t mangle -I PREROUTING -p tcp -m set --match-set allow-list6 src -j ACCEPT
ip6tables -t mangle -A PREROUTING -p tcp --destination $ip6address --destination-port $ORPort -m recent --name tor-ddos6 --set
ip6tables -t mangle -A PREROUTING -p tcp --destination $ip6address --destination-port $ORPort2 -m recent --name tor2-ddos6 --set
ip6tables -t mangle -A PREROUTING -p tcp --syn --destination $ip6address --dport $ORPort -m conntrack --ctstate NEW -m hashlimit --hashlimit-name TOR6 --hashlimit-mode srcip --hashlimit-srcmask 128 --hashlimit-above 2/sec --hashlimit-burst 3 --hashlimit-htable-expire 3600 -j SET --add-set persec6 src
ip6tables -t mangle -A PREROUTING -p tcp --syn --destination $ip6address --dport $ORPort2 -m conntrack --ctstate NEW -m hashlimit --hashlimit-name TOR26 --hashlimit-mode srcip --hashlimit-srcmask 128 --hashlimit-above 2/sec --hashlimit-burst 3 --hashlimit-htable-expire 3600 -j SET --add-set persec26 src
ip6tables -t mangle -A PREROUTING -p tcp --destination $ip6address --destination-port $ORPort -m connlimit --connlimit-mask 128 --connlimit-above 4 -j SET --add-set tor-ddos6 src
ip6tables -t mangle -A PREROUTING -p tcp --destination $ip6address --destination-port $ORPort2 -m connlimit --connlimit-mask 128 --connlimit-above 4 -j SET --add-set tor2-ddos6 src
ip6tables -t mangle -A PREROUTING -p tcp --syn --destination $ip6address --destination-port $ORPort -m connlimit --connlimit-mask 128 --connlimit-above 4 -j DROP
ip6tables -t mangle -A PREROUTING -p tcp --syn --destination $ip6address --destination-port $ORPort2 -m connlimit --connlimit-mask 128 --connlimit-above 4 -j DROP
ip6tables -t mangle -A PREROUTING -p tcp -m set --match-set persec6 src -j DROP
ip6tables -t mangle -A PREROUTING -p tcp -m set --match-set persec26 src -j DROP
ip6tables -t mangle -A PREROUTING -p tcp -m set --match-set tor-ddos6 src -j DROP
ip6tables -t mangle -A PREROUTING -p tcp -m set --match-set tor2-ddos6 src -j DROP
ip6tables -t mangle -A PREROUTING -p tcp --destination $ip6address --destination-port $ORPort -j ACCEPT
ip6tables -t mangle -A PREROUTING -p tcp --destination $ip6address --destination-port $ORPort2 -j ACCEPT
