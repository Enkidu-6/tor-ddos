#!/bin/bash
# set -x
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/authorities-v4.txt' | sed -e '1,3d' > /var/tmp/allow
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/snowflake.txt' | sed -e '1,3d' >> /var/tmp/allow
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/authorities-v6.txt' | sed -e '1,3d' > /var/tmp/allow6
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/snowflake-v6.txt' | sed -e '1,3d' >> /var/tmp/allow6
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/dual-or.txt' | sed -e '1,3d' > /var/tmp/multi
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/dual-or-v6.txt' | sed -e '1,3d' > /var/tmp/multi6
/usr/sbin/ipset flush allow-list
for i in `cat /var/tmp/allow` ;
do
/usr/sbin/ipset add -exist allow-list $i
done;
/usr/sbin/ipset flush allow-list6
for i in `cat /var/tmp/allow6` ;
do
/usr/sbin/ipset add -exist allow-list6 $i
done;
/usr/sbin/ipset flush dual-or
for i in `cat /var/tmp/multi` ;
do
/usr/sbin/ipset add -exist dual-or $i
done;
/usr/sbin/ipset flush dual-or6
for i in `cat /var/tmp/multi6` ;
do
/usr/sbin/ipset add -exist dual-or6 $i
done;
/bin/rm -r /var/tmp/allow /var/tmp/allow6 /var/tmp/multi /var/tmp/multi6
