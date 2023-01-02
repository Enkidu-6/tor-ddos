#!/bin/bash
# set -x
# This script depends on conntrack utilities package (apt get conntrack). If you don't have the nf_conntrack file on your system you can use this script. 
if [[ ! -e /var/tmp/file2 ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/relays-v4.txt' > /var/tmp/file2
elif
[[ $(find "/var/tmp/file2" -mmin +60 -print) ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/relays-v4.txt' > /var/tmp/file2
fi
if [[ ! -e /var/tmp/dual-or ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/dual-or.txt' > /var/tmp/dual-or
elif
[[ $(find "/var/tmp/dual-or" -mmin +60 -print) ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/dual-or.txt' > /var/tmp/dual-or
fi
echo -e "\033[1;32mConntrack count:\033[0m"
echo -e "   \033[1;36m`conntrack -C`\033[0m"
echo -e "\033[1;32mIPs with more than 2 connections:\033[0;30m"
conntrack -L | grep ESTABLISHED | awk '{ print $5 }' | awk -F= '{ print $2 }' | sort | uniq -c > /var/tmp/5
conntrack -L -f ipv6 | grep ESTABLISHED | awk '{ print $5 }' | awk -F= '{ print $2 }' | sort | uniq -c >> /var/tmp/5
cd /var/tmp
echo -e "\033[1;37m`cat 5 | grep -v ' 1 ' | grep -v ' 2 '`\033[0m"
echo -e "\033[1;32mTwo connections, Relays:\033[0m"
cat 5 | grep ' 2 ' | awk '{ print $2 }' > 6 
echo -e "\033[1;37m There are \033[1;36m`cat 6 | wc -l`\033[1;37m IPs with two connections \033[1;36m`perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  6 file2 | wc -l` \033[1;37mof which are Relays\033[0m"
echo -e "\033[1;32mTwo connections, dual-or:\033[0m"
echo -e "\033[1;37m There are \033[1;36m`cat 6 | wc -l`\033[1;37m IPs with two connections \033[1;36m`perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  6 dual-or | wc -l` \033[1;37mof which are Dual-OR Relays\033[0m"
echo -e "\033[1;32mOne connection, Relays:\033[0m"
cat 5 | grep ' 1 ' | awk '{ print $2 }' > 7
echo -e "\033[1;37m There are \033[1;36m`cat 7 | wc -l`\033[1;37m IPs with one connection \033[1;36m`perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  7 file2 | wc -l` \033[1;37mof which are Relays\033[0m"
echo -e "\033[1;32mOne connection, dual-or:\033[0m"
echo -e "\033[1;37m There are \033[1;36m`cat 7 | wc -l`\033[1;37m IPs with one connection \033[1;36m`perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  7 dual-or | wc -l` \033[1;37mof which are Dual-OR Relays\033[0m"
/bin/rm -r 5 6 7
