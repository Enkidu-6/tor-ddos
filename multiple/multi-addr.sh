#!/bin/bash
# set -x
iptables-save > /var/tmp/iptablesRules.v4
ip6tables-save > /var/tmp/ip6tablesRules.v4
iptables -t mangle -F
ip6tables -t mangle -F
sleep 1
sysctl net.ipv4.ip_local_port_range="1025 65535"
echo 20 > /proc/sys/net/ipv4/tcp_fin_timeout
modprobe xt_recent ip_list_tot=10000
#change the addresses to two of your IP addresses at a time
ipaddress1=10.1.1.2
ipaddress2=10.1.1.3
#ORPorts for the first and second IP address
ORPort1=443
ORPort2=443
#change the addresses to two of your IPV6 addresses at a time
ip6address1=xxxx:xxxx::xxxx
ip6address2=xxxx:xxxx::xxxx
ipset create -exist allow-list hash:ip
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/authorities-v4.txt' | sed -e '1,3d' > /var/tmp/allow
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/snowflake.txt' | sed -e '1,3d' >> /var/tmp/allow
for i in `cat /var/tmp/allow` ;
do
ipset add -exist allow-list $i
done;
ipset create tor-$ipaddress1 hash:ip family inet hashsize 4096 timeout 43200
ipset create tor-$ipaddress2 hash:ip family inet hashsize 4096 timeout 43200
iptables -t mangle -I PREROUTING -p tcp --destination $ipaddress1 --dport $ORPort1 -m set --match-set allow-list src -j ACCEPT
iptables -t mangle -I PREROUTING -p tcp --destination $ipaddress2 --dport $ORPort2 -m set --match-set allow-list src -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress1 --destination-port $ORPort1 -m recent --name ddos-$ipaddress1 --set
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress2 --destination-port $ORPort2 -m recent --name ddos-$ipaddress2 --set
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress1 --destination-port $ORPort1 -m connlimit --connlimit-mask 32 --connlimit-above 2 -j SET --add-set tor-$ipaddress1 src
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress2 --destination-port $ORPort2 -m connlimit --connlimit-mask 32 --connlimit-above 2 -j SET --add-set tor-$ipaddress2 src
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress1 -m set --match-set tor-$ipaddress1 src -j DROP
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress2 -m set --match-set tor-$ipaddress2 src -j DROP
iptables -t mangle -A PREROUTING -p tcp --syn --destination $ipaddress1 --destination-port $ORPort1 -m connlimit --connlimit-mask 32 --connlimit-above 4 -j DROP
iptables -t mangle -A PREROUTING -p tcp --syn --destination $ipaddress2 --destination-port $ORPort2 -m connlimit --connlimit-mask 32 --connlimit-above 4 -j DROP
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress1 --destination-port $ORPort1 -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress2 --destination-port $ORPort2 -j ACCEPT
ipset create -exist allow-list6 hash:ip family inet6
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/authorities-v6.txt' | sed -e '1,3d' > /var/tmp/allow6
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/snowflake-v6.txt' | sed -e '1,3d' >> /var/tmp/allow6
for i in `cat /var/tmp/allow6` ;
do
ipset add -exist allow-list6 $i
done;
ipset create tor-$ip6address1 hash:ip family inet6 hashsize 4096 timeout 43200
ipset create tor-$ip6address2 hash:ip family inet6 hashsize 4096 timeout 43200
ip6tables -t mangle -I PREROUTING -p tcp --destination $ip6address1 --dport $ORPort1 -m set --match-set allow-list6 src -j ACCEPT
ip6tables -t mangle -I PREROUTING -p tcp --destination $ip6address2 --dport $ORPort2 -m set --match-set allow-list6 src -j ACCEPT
ip6tables -t mangle -A PREROUTING -p tcp --destination $ip6address1 --destination-port $ORPort1 -m recent --name ddos6-$ip6address1 --set
ip6tables -t mangle -A PREROUTING -p tcp --destination $ip6address2 --destination-port $ORPort2 -m recent --name ddos6-$ip6address2 --set
ip6tables -t mangle -A PREROUTING -p tcp --destination $ip6address1 --destination-port $ORPort1 -m connlimit --connlimit-mask 128 --connlimit-above 2 -j SET --add-set tor-$ip6address1 src
ip6tables -t mangle -A PREROUTING -p tcp --destination $ip6address2 --destination-port $ORPort2 -m connlimit --connlimit-mask 128 --connlimit-above 2 -j SET --add-set tor-$ip6address2 src
ip6tables -t mangle -A PREROUTING -p tcp -m set --match-set tor-$ip6address1 src -j DROP
ip6tables -t mangle -A PREROUTING -p tcp -m set --match-set tor-$ip6address2 src -j DROP
ip6tables -t mangle -A PREROUTING -p tcp --syn --destination $ip6address1 --destination-port $ORPort1 -m connlimit --connlimit-mask 128 --connlimit-above 4 -j DROP
ip6tables -t mangle -A PREROUTING -p tcp --syn --destination $ip6address2 --destination-port $ORPort2 -m connlimit --connlimit-mask 128 --connlimit-above 4 -j DROP
ip6tables -t mangle -A PREROUTING -p tcp --destination $ip6address1 --destination-port $ORPort1 -j ACCEPT
ip6tables -t mangle -A PREROUTING -p tcp --destination $ip6address2 --destination-port $ORPort2 -j ACCEPT
