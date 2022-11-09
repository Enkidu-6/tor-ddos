#!/bin/bash
# set -x
ip6tables-save > /var/tmp/ip6tablesRules.v4
ip6tables -t mangle -F
# Change this number to your own ORPort if it's not 443
ORPort=443
ipset create -exist allow-list6 hash:ip family inet6
ipset add -exist allow-list6 2001:638:a000:4140::ffff:189
ipset add -exist allow-list6 2001:678:558:1000::244
ipset add -exist allow-list6 2001:67c:289c::9
ipset add -exist allow-list6 2001:858:2:2:aabb:0:563b:1526
ipset add -exist allow-list6 2607:8500:154::3
ipset add -exist allow-list6 2610:1c0:0:5::131
ipset add -exist allow-list6 2620:13:4000:6000::1000:118
ipset add -exist allow-list6 2a0c:dd40:1:b::42
ipset create tor-ddos6 hash:ip family inet6 hashsize 4096 timeout 43200
ip6tables -t mangle -I PREROUTING -p tcp -m set --match-set allow-list6 src -j ACCEPT
ip6tables -t mangle -A PREROUTING -p tcp --syn --destination-port $ORPort -m hashlimit --hashlimit-name TOR6-$ORPort --hashlimit-mode srcip --hashlimit-srcmask 128 --hashlimit-above 1/minute --hashlimit-burst 5 --hashlimit-htable-expire 60000 -j DROP
ip6tables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -m recent --name tor-ddos6 --set
ip6tables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -m connlimit --connlimit-mask 128 --connlimit-above 4 -j SET --add-set tor-ddos6 src
ip6tables -t mangle -A PREROUTING -p tcp --syn --destination-port $ORPort -m connlimit --connlimit-mask 128 --connlimit-above 4 -j DROP
ip6tables -t mangle -A PREROUTING -p tcp -m set --match-set persec6 src -j DROP
ip6tables -t mangle -A PREROUTING -p tcp --destination-port $ORPort -j ACCEPT
