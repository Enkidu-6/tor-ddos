#!/bin/bash
# set -x
ipset flush allow-list
ipset flush allow-list6
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/authorities-v4.txt' | sed -e '1,3d' > /var/tmp/allow
getent ahostsv4 snowflake-01.torproject.net | awk '{ print $1 }' | sort -u >> /var/tmp/allow
for i in `cat /var/tmp/allow` ;
do
/usr/sbin/ipset add -exist allow-list $i
done;
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/authorities-v6.txt' | sed -e '1,3d' > /var/tmp/allow6
getent ahostsv6 snowflake-01.torproject.net | awk '{ print $1 }' | sort -u >> /var/tmp/allow6
for i in `cat /var/tmp/allow6` ;
do
/usr/sbin/ipset add -exist allow-list6 $i
done;
