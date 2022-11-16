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
cat -s https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/authorities-v4.txt | sed -e '1,3d' > /var/tmp/allow
getent ahostsv4 snowflake-01.torproject.net | awk '{ print $1 }' | sort -u >> /var/tmp/allow
for i in `cat /var/tmp/allow` ;
do
ipset add -exist allow-list $i
done;
ipset create tor-ddos hash:ip family inet hashsize 4096 timeout 43200
iptables -t mangle -I PREROUTING -p tcp -m set --match-set allow-list src -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp --syn --destination-port $ORPort -m hashlimit --hashlimit-name TOR-$ORPort --hashlimit-mode srcip --hashlimit-srcmask 32 --hashlimit-above 1/minute --hashlimit-burst 5 --hashlimit-htable-expire 60000 -j DROP
iptables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -m recent --name tor-ddos --set
iptables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -m connlimit --connlimit-mask 32 --connlimit-above 4 -j SET --add-set tor-ddos src
iptables -t mangle -A PREROUTING -p tcp --syn --destination-port $ORPort -m connlimit --connlimit-mask 32 --connlimit-above 4 -j DROP
iptables -t mangle -A PREROUTING -p tcp -m set --match-set tor-ddos src -j DROP
iptables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -j ACCEPT
