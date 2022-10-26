#!/bin/bas
# set -x
ipset -L tor-ddos | awk '{print $1}' > /var/tmp/file1
ipset -L persec | awk '{print $1}' >> /var/tmp/file1
curl https://wcbsecurity.com/relays.txt > /var/tmp/file2
cd /var/tmp
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  file1 file2
