#!/bin/bash
# set -x
if [[ ! -e /var/tmp/file2 ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/dual-or.txt' > /var/tmp/dual-or
elif
[[ $(find "/var/tmp/file2" -mmin +60 -print) ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/dual-or.txt' > /var/tmp/dual-or
fi
for i in `cat ipv4.txt | sed 's/:/-/'`;
do
/usr/sbin/ipset -L tor-$i | awk '{print $1}' > /var/tmp/$i
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  /var/tmp/$i /var/tmp/dual-or > /var/tmp/dual-$i
for b in `cat /var/tmp/dual-$i` ;
do
/usr/sbin/ipset del tor-$i $b
done
/bin/rm -r /var/tmp/$i /var/tmp/dual-$i;
done
