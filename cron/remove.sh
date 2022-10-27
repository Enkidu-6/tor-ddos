#!/bin/bash
# set -x
ipset -L tor-ddos | awk '{print $1}' > /var/tmp/file1
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/relays-v4.txt' > /var/tmp/file2
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  file1 file2 > /var/tmp/remove
cd /var/tmp ;
for i in `cat remove` ;
do
ipset del tor-ddos $i
done;
