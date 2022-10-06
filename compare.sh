#!/bin/bash
# set -x
ipset -L tor-ddos | awk '{print $1}' > /var/tmp/file1
ipset -L persec | awk '{print $1}' >> /var/tmp/file1
curl https://lists.fissionrelays.net/tor/relays-ipv4.txt > /var/tmp/file2
cd /var/tmp
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  file1 file2
