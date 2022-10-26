#!/bin/bash
# set -x
ipset -L tor2-ddos | awk '{print $1}' > /var/tmp/file3
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/dual-or.txt' > /var/tmp/dual-or2
cd /var/tmp
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  file3 dual-or2