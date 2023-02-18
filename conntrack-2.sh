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

if [[ ! -e /var/tmp/multi-or ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/above2-or.txt' > /var/tmp/multi-or
elif
[[ $(find "/var/tmp/multi-or" -mmin +60 -print) ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/above2-or.txt' > /var/tmp/multi-or
fi

if [[ ! -e /var/tmp/snow ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/snowflake.txt' > /var/tmp/snow
elif
[[ $(find "/var/tmp/snow" -mmin +60 -print) ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/snowflake.txt' > /var/tmp/snow
fi

echo -e "\033[1;32mConntrack count:\033[0m"
echo -e "   \033[1;36m`conntrack -C`\033[0m"

echo -e "\033[1;32mIPs with more than 2 connections:\033[0;30m"
conntrack -L | grep ESTABLISHED | awk '{ print $5 }' | awk -F= '{ print $2 }' | sort | uniq -c > /var/tmp/5
conntrack -L -f ipv6 | grep ESTABLISHED | awk '{ print $5 }' | awk -F= '{ print $2 }' | sort | uniq -c >> /var/tmp/5
cd /var/tmp
echo -e "\033[1;37m`cat 5 | grep -v ' 1 ' | grep -v ' 2 '`\033[0m"

echo -e "\033[1;32mIPs with More than Two connections:\033[0m"
cat 5 | grep -v ' 1 ' | grep -v ' 2 ' | awk '{ print $2 }' > 8

echo -e "\033[1;37m There are \033[1;36m`cat 8 | wc -l`\033[1;37m IPs With More than Two connections" 
echo -e "\033[1;36m           `perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  8 file2 | wc -l` \033[1;37mRelays" 
echo -e "\033[1;36m           `perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  8 dual-or | wc -l` \033[1;37mMulti-OR"
echo -e "\033[1;36m           `perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  8 snow | wc -l` \033[1;37mSnowflake\033[0m" 

echo -e "\033[1;32mIPs with Two connections:\033[0m"
cat 5 | grep ' 2 ' | awk '{ print $2 }' > 6 

echo -e "\033[1;37m There are \033[1;36m`cat 6 | wc -l`\033[1;37m IPs with Two connections"
echo -e "\033[1;36m           `perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  6 file2 | wc -l` \033[1;37mRelays\033[0m"
echo -e "\033[1;36m           `perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  6 dual-or | wc -l` \033[1;37mMulti-OR\033[0m"

echo -e "\033[1;32mIPs with One connection:\033[0m"
cat 5 | grep ' 1 ' | awk '{ print $2 }' > 7

echo -e "\033[1;37m There are \033[1;36m`cat 7 | wc -l`\033[1;37m IPs With One connection"
echo -e "\033[1;36m           `perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  7 file2 | wc -l` \033[1;37mRelays"
echo -e "\033[1;36m           `perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  7 dual-or | wc -l` \033[1;37mMulti-OR\033[0m"
/bin/rm -r 5 6 7 8 
