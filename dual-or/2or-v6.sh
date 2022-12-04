#!/bin/bash
# set -x
ip6tables-save > /var/tmp/ip6tablesRules.v4
ip6tables -t mangle -F
# Change this number to your own ORPort if it's not 443
ORPort=443
# Change this number to your second ORPort if it's not 80
ORPort2=80
ipset create -exist allow-list6 hash:ip family inet6
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/authorities-v6.txt' | sed -e '1,3d' > /var/tmp/allow6
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/snowflake-v6.txt' | sed -e '1,3d' >> /var/tmp/allow6
for i in `cat /var/tmp/allow6` ;
do
ipset add -exist allow-list6 $i
done;
ipset create tor-ddos6 hash:ip family inet6 hashsize 4096 timeout 43200
ipset create tor2-ddos6 hash:ip family inet6 hashsize 4096 timeout 43200
ip6tables -t mangle -I PREROUTING -p tcp -m set --match-set allow-list6 src -j ACCEPT
ip6tables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -m recent --name tor-ddos6 --set
ip6tables -t mangle -A PREROUTING -p tcp --destination-port $ORPort2 -m recent --name tor2-ddos6 --set
ip6tables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -m connlimit --connlimit-mask 128 --connlimit-above 2 -j SET --add-set tor-ddos6 src
ip6tables -t mangle -A PREROUTING -p tcp --destination-port $ORPort2 -m connlimit --connlimit-mask 128 --connlimit-above 2 -j SET --add-set tor2-ddos6 src
ip6tables -t mangle -A PREROUTING -p tcp -m set --match-set tor-ddos6 src -j DROP
ip6tables -t mangle -A PREROUTING -p tcp -m set --match-set tor2-ddos6 src -j DROP
ip6tables -t mangle -A PREROUTING -p tcp --syn --destination-port $ORPort -m connlimit --connlimit-mask 128 --connlimit-above 4 -j DROP
ip6tables -t mangle -A PREROUTING -p tcp --syn --destination-port $ORPort2 -m connlimit --connlimit-mask 128 --connlimit-above 4 -j DROP
ip6tables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -j ACCEPT
ip6tables -t mangle -A PREROUTING -p tcp --destination-port $ORPort2 -j ACCEPT
