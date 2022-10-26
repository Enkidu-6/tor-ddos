#!/bin/bash
# set -x
ipset -L tor2-ddos | awk '{print $1}' > /var/tmp/file3
curl https://wcbsecurity.com/relays.txt > /var/tmp/file2
cd /var/tmp
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  file3 file2
