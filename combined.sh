#!/bin/bash
# set -x
iptables-save > /var/tmp/iptablesRules.v4
ip6tables-save > /var/tmp/ip6tablesRules.v4
iptables -t mangle -F
ip6tables -t mangle -F
sleep 1
sysctl net.ipv4.ip_local_port_range="10000 65000"
echo 20 > /proc/sys/net/ipv4/tcp_fin_timeout
modprobe xt_recent ip_list_tot=10000
# Change this number to your own ORPort if it's not 443
ORPort=443
ipset create -exist allow-list hash:ip
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/authorities-v4.txt' | sed -e '1,3d' > /var/tmp/allow
getent ahostsv4 snowflake-01.torproject.net | awk '{ print $1 }' | sort -u >> /var/tmp/allow
for i in `cat /var/tmp/allow` ;
do
ipset add -exist allow-list $i
done;
ipset create tor-ddos hash:ip family inet hashsize 4096 timeout 43200
iptables -t mangle -I PREROUTING -p tcp -m set --match-set allow-list src -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -m recent --name tor-ddos --set
iptables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -m connlimit --connlimit-mask 32 --connlimit-above 2 -j SET --add-set tor-ddos src
iptables -t mangle -A PREROUTING -p tcp -m set --match-set tor-ddos src -j DROP
iptables -t mangle -A PREROUTING -p tcp --syn --destination-port $ORPort -m connlimit --connlimit-mask 32 --connlimit-above 4 -j DROP
iptables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -j ACCEPT
ipset create -exist allow-list6 hash:ip family inet6
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/authorities-v6.txt' | sed -e '1,3d' > /var/tmp/allow6
getent ahostsv6 snowflake-01.torproject.net | awk '{ print $1 }' | sort -u >> /var/tmp/allow6
for i in `cat /var/tmp/allow6` ;
do
ipset add -exist allow-list6 $i
done;
ipset create tor-ddos6 hash:ip family inet6 hashsize 4096 timeout 43200
ip6tables -t mangle -I PREROUTING -p tcp -m set --match-set allow-list6 src -j ACCEPT
ip6tables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -m recent --name tor-ddos6 --set
ip6tables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -m connlimit --connlimit-mask 128 --connlimit-above 2 -j SET --add-set tor-ddos6 src
ip6tables -t mangle -A PREROUTING -p tcp -m set --match-set tor-ddos6 src -j DROP
ip6tables -t mangle -A PREROUTING -p tcp --syn --destination-port $ORPort -m connlimit --connlimit-mask 128 --connlimit-above 4 -j DROP
ip6tables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -j ACCEPT
