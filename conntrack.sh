#!/bin/bash
# set -x
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/relays-v4.txt' > /var/tmp/file2
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/dual-or.txt' > /var/tmp/dual-or
echo -e "\033[0;32mConntrack count:\033[0m"
echo -e "   \033[1;36m`cat /proc/sys/net/netfilter/nf_conntrack_count`\033[0m"
echo -e "\033[0;32mIPs with more than 2 connections:\033[0m"
cat /proc/net/nf_conntrack | grep ESTABLISHED | awk '{ print $7 }' | awk -F= '{ print $2 }' | sort | uniq -c > /var/tmp/5
cd /var/tmp
cat 5 | grep -v ' 1 ' | grep -v ' 2 '
echo -e "\033[0;32mTwo connections, Relays:\033[0m"
cat 5 | grep ' 2 ' | awk '{ print $2 }' > 6 
echo -e "   \033[1;36m`perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  6 file2 | wc -l`\033[0m Relays out of \033[1;36m`cat 6 | wc -l` \033[0m"IPs with two connections
echo -e "\033[0;32mTwo connections, dual-or:\033[0m"
echo -e "   \033[1;36m`perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  6 dual-or | wc -l`\033[0m Dual-OR Relays out of \033[1;36m`cat 6 | wc -l` \033[0m"IPs with two connections
echo -e "\033[0;32mOne connection, Relays:\033[0m"
cat 5 | grep ' 1 ' | awk '{ print $2 }' > 7
echo -e "   \033[1;36m`perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  7 file2 | wc -l`\033[0m Relays out of \033[1;36m`cat 7 | wc -l` \033[0m"IPs with one connection
echo -e "\033[0;32mOne connection, dual-or:\033[0m"
echo -e "   \033[1;36m`perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  7 dual-or | wc -l`\033[0m Dual-OR Relays out of \033[1;36m`cat 7 | wc -l` \033[0m"IPs with one connection
/bin/rm -r 5 6 7
