#!/bin/bash
# set -x
/usr/sbin/ipset -L tor2-ddos | awk '{print $1}' > /var/tmp/file3
if [[ ! -e /var/tmp/file2 ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/relays-v4.txt' > /var/tmp/file2
elif
[[ $(find "/var/tmp/file2" -mmin +60 -print) ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/relays-v4.txt' > /var/tmp/file2
fi
cd /var/tmp
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  file3 file2 > remove2
for i in `cat remove2` ;
do
/usr/sbin/ipset del tor2-ddos $i
done;
