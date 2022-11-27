#!/bin/bash
# set -x
iptables-save > /var/tmp/iptablesRules-pre-update.v4
ip6tables-save > /var/tmp/ip6tablesRules-pre-update.v4
ipset save -f /var/tmp/ipset.full
iptables -t mangle -F
ip6tables -t mangle -F
sleep 1
ipset destroy
sysctl net.ipv4.ip_local_port_range="10000 65000"
echo 20 > /proc/sys/net/ipv4/tcp_fin_timeout
modprobe xt_recent ip_list_tot=10000
ipset restore -exist -f /var/tmp/ipset.full
sleep 2
ipset flush allow-list
ipset flush allow-list6
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/authorities-v4.txt' | sed -e '1,3d' > /var/tmp/allow
getent ahostsv4 snowflake-01.torproject.net | awk '{ print $1 }' | sort -u >> /var/tmp/allow
for i in `cat /var/tmp/allow` ;
do
ipset add -exist allow-list $i
done;
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/authorities-v6.txt' | sed -e '1,3d' > /var/tmp/allow6
getent ahostsv6 snowflake-01.torproject.net | awk '{ print $1 }' | sort -u >> /var/tmp/allow6
for i in `cat /var/tmp/allow6` ;
do
ipset add -exist allow-list6 $i
done;
# Change this to the IP address of your VM
ipaddress=10.1.1.2
# Change this to the IPv6 address of your VM
ip6address=xxxx:xxxx::xxxx
# Change this number to your own ORPort if it's not 443
ORPort=443
iptables -t mangle -I PREROUTING -p tcp -m set --match-set allow-list src -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort -m recent --name tor-ddos --set
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort -m connlimit --connlimit-mask 32 --connlimit-above 2 -j SET --add-set tor-ddos src
iptables -t mangle -A PREROUTING -p tcp -m set --match-set tor-ddos src -j DROP
iptables -t mangle -A PREROUTING -p tcp --syn --destination $ipaddress --destination-port $ORPort -m connlimit --connlimit-mask 32 --connlimit-above 4 -j DROP
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort -j ACCEPT
ip6tables -t mangle -I PREROUTING -p tcp -m set --match-set allow-list6 src -j ACCEPT
ip6tables -t mangle -A PREROUTING -p tcp --destination $ip6address --destination-port $ORPort -m recent --name tor-ddos6 --set
ip6tables -t mangle -A PREROUTING -p tcp --destination $ip6address --destination-port $ORPort -m connlimit --connlimit-mask 128 --connlimit-above 2 -j SET --add-set tor-ddos6 src
ip6tables -t mangle -A PREROUTING -p tcp -m set --match-set tor-ddos6 src -j DROP
ip6tables -t mangle -A PREROUTING -p tcp --syn --destination $ip6address --destination-port $ORPort -m connlimit --connlimit-mask 128 --connlimit-above 4 -j DROP
ip6tables -t mangle -A PREROUTING -p tcp --destination $ip6address --destination-port $ORPort -j ACCEPT
