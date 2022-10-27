#!/bin/bash
# set -x
/usr/sbin/ipset -L tor-ddos | awk '{print $1}' > /var/tmp/file1
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/dual-or.txt' > /var/tmp/dual-or
cd /var/tmp
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  file1 dual-or > dual
for i in `cat dual` ;
do
/usr/sbin/ipset del tor-ddos $i
done;
