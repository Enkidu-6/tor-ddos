#!/bin/bash
# set -x
green='\033[1;32m'
blue='\033[1;36m'
white='\033[1;37m'
plain='\033[0m'

if [[ ! -e /proc/net/nf_conntrack ]]; then
    clear
    echo -e "${green}Your system does not come with nf_conntrack. Please install\nconntrack utilities if you don't already have it.\n'apt install conntrack' and use conntrack-2.sh${plain}"
    exit 1
fi

if [[ ! -e /var/tmp/file2 ]]; then
    curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/relays-v4.txt' >/var/tmp/file2
elif
    [[ $(find "/var/tmp/file2" -mmin +60 -print) ]]
then
    curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/relays-v4.txt' >/var/tmp/file2
fi

if [[ ! -e /var/tmp/multi ]]; then
    curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/above1-or.txt' >/var/tmp/multi
elif
    [[ $(find "/var/tmp/multi" -mmin +60 -print) ]]
then
    curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/above1-or.txt' >/var/tmp/multi
fi

if [[ ! -e /var/tmp/snow ]]; then
    curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/snowflake.txt' >/var/tmp/snow
elif
    [[ $(find "/var/tmp/snow" -mmin +60 -print) ]]
then
    curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/snowflake.txt' >/var/tmp/snow
fi

echo -e "${green}Conntrack count:${plain}"
echo -e "   ${blue}$(cat /proc/sys/net/netfilter/nf_conntrack_count)${plain}"

echo -e "${green}IPs with more than Two connections:${plain}"
cat /proc/net/nf_conntrack | grep ESTABLISHED | awk '{ print $7 }' | awk -F= '{ print $2 }' | sort | uniq -c >/var/tmp/5
cd /var/tmp
echo -e "${white}$(cat 5 | grep -v ' 1 ' | grep -v ' 2 ' | sort -n)${plain}"

echo -e "${green}IPs with More than Two connections:${plain}"
cat 5 | grep -v ' 1 ' | grep -v ' 2 ' | awk '{ print $2 }' >8

echo -e "${white} There are ${blue}$(cat 8 | wc -l)${white} IPs With More than Two connections"
echo -e "${blue}           $(perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/' 8 file2 | wc -l) ${white}Relays"
echo -e "${blue}           $(perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/' 8 multi | wc -l) ${white}Multi-OR"
echo -e "${blue}           $(perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/' 8 snow | wc -l) ${white}Snowflake${plain}"

echo -e "${green}IPs with Two connections:${plain}"
cat 5 | grep ' 2 ' | awk '{ print $2 }' >6

echo -e "${white} There are ${blue}$(cat 6 | wc -l)${white} IPs With Two connections"
echo -e "${blue}           $(perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/' 6 file2 | wc -l) ${white}Relays${plain}"
echo -e "${blue}           $(perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/' 6 multi | wc -l) ${white}Multi-OR${plain}"
echo -e "${blue}           $(perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/' 6 snow | wc -l) ${white}Snowflake${plain}"

echo -e "${green}IPs with One connection:${plain}"
cat 5 | grep ' 1 ' | awk '{ print $2 }' >7

echo -e "${white} There are ${blue}$(cat 7 | wc -l)${white} IPs With One connection"
echo -e "${blue}           $(perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/' 7 file2 | wc -l) ${white}Relays"
echo -e "${blue}           $(perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/' 7 multi | wc -l) ${white}Multi-OR${plain}"
echo -e "${blue}           $(perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/' 7 snow | wc -l) ${white}Snowflake${plain}"
/bin/rm -r 5 6 7 8
