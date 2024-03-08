#!/bin/bash
# set -x
if [[ ! -e /var/tmp/file2 ]]; then
    curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/relays-v4.txt' >/var/tmp/file2
elif
    [[ $(find "/var/tmp/file2" -mmin +60 -print) ]]
then
    curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/relays-v4.txt' >/var/tmp/file2
fi

for i in $(cat ipv4.txt | sed 's/:/-/'); do
    /usr/sbin/ipset -L tor-$i | awk '{print $1}' >/var/tmp/$i
    perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/' /var/tmp/$i /var/tmp/file2 >/var/tmp/remove-$i
    for b in $(cat /var/tmp/remove-$i); do
        /usr/sbin/ipset del tor-$i $b
    done
    /bin/rm -r /var/tmp/$i /var/tmp/remove-$i
done
