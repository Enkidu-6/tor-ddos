#!/bin/bash
# set -x
date >> /var/tmp/ipset.log
date >> /var/tmp/relays.log
/usr/sbin/ipset -L tor-ddos | wc -l >> /var/tmp/ipset.log
echo '----------------------------' >> /var/tmp/ipset.log
/usr/sbin/ipset -L tor-ddos | awk '{print $1}' > /var/tmp/file1
if [[ ! -e /var/tmp/file2 ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/relays-v4.txt' > /var/tmp/file2
elif
[[ $(find "/var/tmp/file2" -mmin +60 -print) ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/relays-v4.txt' > /var/tmp/file2
fi
cd /var/tmp
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  file1 file2 >> /var/tmp/relays.log
echo '----------------------------' >> /var/tmp/relays.log
