#!/bin/bash
# set -x
if [[ ! -e /proc/net/nf_conntrack ]]; then
clear
echo -e "\033[1;32mYour system does not come with nf_conntrack. Please install\nconntrack utilities if you don't already have it.\n'apt install conntrack' and use conntrack-2.sh\033[0m"
exit 1
fi

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
echo -e "   \033[1;36m`cat /proc/sys/net/netfilter/nf_conntrack_count`\033[0m"

echo -e "\033[1;32mIPs with more than Two connections:\033[0m"
cat /proc/net/nf_conntrack | grep ESTABLISHED | awk '{ print $7 }' | awk -F= '{ print $2 }' | sort | uniq -c > /var/tmp/5
cd /var/tmp
echo -e "\033[1;37m`cat 5 | grep -v ' 1 ' | grep -v ' 2 '`\033[0m"

echo -e "\033[1;32mIPs with More than Two connections:\033[0m"
cat 5 | grep -v ' 1 ' | grep -v ' 2 ' | awk '{ print $2 }' > 8

echo -e "\033[1;37m There are \033[1;36m`cat 8 | wc -l`\033[1;37m IPs With More than Two connections" 
echo -e "\033[1;36m           `perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  8 file2 | wc -l` \033[1;37mRelays" 
echo -e "\033[1;36m           `perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  8 multi-or | wc -l` \033[1;37mmulti-OR"
echo -e "\033[1;36m           `perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  8 snow | wc -l` \033[1;37msnowflake\033[0m" 

echo -e "\033[1;32mIPs with Two connections:\033[0m"
cat 5 | grep ' 2 ' | awk '{ print $2 }' > 6 

echo -e "\033[1;37m There are \033[1;36m`cat 6 | wc -l`\033[1;37m IPs With Two connections"
echo -e "\033[1;36m           `perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  6 file2 | wc -l` \033[1;37mRelays\033[0m"
echo -e "\033[1;36m           `perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  6 dual-or | wc -l` \033[1;37mDual-OR\033[0m"

echo -e "\033[1;32mIPs with One connection:\033[0m"
cat 5 | grep ' 1 ' | awk '{ print $2 }' > 7

echo -e "\033[1;37m There are \033[1;36m`cat 7 | wc -l`\033[1;37m IPs With One connection"
echo -e "\033[1;36m           `perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  7 file2 | wc -l` \033[1;37mRelays"
echo -e "\033[1;36m           `perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  7 dual-or | wc -l` \033[1;37mDual-OR\033[0m"
/bin/rm -r 5 6 7 8 snow
