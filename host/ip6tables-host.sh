#!/bin/bash
# set -x
ip6tables-save > /var/tmp/ip6tablesRules.v4
# Change this to the IPv6 address of your VM
ip6address=xxxx:xxxx::xxxx
# Change this number to your own ORPort if it's not 443
ORPort=443
ipset create -exist allow-list6 hash:ip family inet6
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/authorities-v6.txt' | sed -e '1,3d' > /var/tmp/allow6
getent ahostsv6 snowflake-01.torproject.net | awk '{ print $1 }' | sort -u >> /var/tmp/allow6
for i in `cat /var/tmp/allow6` ;
do
ipset add -exist allow-list6 $i
done;
ipset create tor-ddos6 hash:ip family inet6 hashsize 4096 timeout 43200
ip6tables -t mangle -I PREROUTING -p tcp -m set --match-set allow-list6 src -j ACCEPT
ip6tables -t mangle -A PREROUTING -p tcp --destination $ip6address --destination-port $ORPort -m recent --name tor-ddos6 --set
ip6tables -t mangle -A PREROUTING -p tcp --destination $ip6address --destination-port $ORPort -m connlimit --connlimit-mask 128 --connlimit-above 2 -j SET --add-set tor-ddos6 src
ip6tables -t mangle -A PREROUTING -p tcp -m set --match-set tor-ddos6 src -j DROP
ip6tables -t mangle -A PREROUTING -p tcp --syn --destination $ip6address --destination-port $ORPort -m connlimit --connlimit-mask 128 --connlimit-above 4 -j DROP
ip6tables -t mangle -A PREROUTING -p tcp --destination $ip6address --destination-port $ORPort -j ACCEPT
