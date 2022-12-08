#!/bin/bash
# set -x
#Change the IP Addresses to your own
ipaddress1=10.1.1.2
ipaddress2=10.1.1.3
/usr/sbin/ipset -L tor-$ipaddress1 | awk '{print $1}' > /var/tmp/$ipaddress1
/usr/sbin/ipset -L tor-$ipaddress2 | awk '{print $1}' > /var/tmp/$ipaddress2
if [[ ! -e /var/tmp/dual-or ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/dual-or.txt' > /var/tmp/dual-or
elif
[[ $(find "/var/tmp/dual-or" -mmin +60 -print) ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/dual-or.txt' > /var/tmp/dual-or
fi
cd /var/tmp
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  $ipaddress1 dual-or > dual-$ipaddress1
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  $ipaddress2 dual-or > dual-$ipaddress2
for i in `cat dual-$ipaddress1` ;
do
/usr/sbin/ipset del tor-$ipaddress1 $i
done;
for i in `cat dual-$ipaddress2` ;
do
/usr/sbin/ipset del tor-$ipaddress2 $i
done;
