#!/bin/bash
# set -x
ipaddress1=10.1.1.2
ipaddress2=10.1.1.3
ipset -L ddos-$ipaddress1 | awk '{print $1}' > /var/tmp/$ipaddress1
ipset -L ddos-$ipaddress2 | awk '{print $1}' > /var/tmp/$ipaddress2
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/relays-v4.txt' > /var/tmp/file2
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/dual-or.txt' > /var/tmp/dual-or
cd /var/tmp
echo -e "\033[0;32mAll relays in Block list $ipaddress1:\033[0m"
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  $ipaddress1 file2
echo -e "\033[0;32mAll relays in Block list $ipaddress2:\033[0m"
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  $ipaddress2 file2
echo -e "\033[0;32mRelays with two Tor instances in Block list $ipaddress1:\033[0m"
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  $ipaddress1 dual-or
echo -e "\033[0;32mRelays with two Tor instances in Block list $ipaddress2:\033[0m"
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  $ipaddress2 dual-or

read -p "Remove All 'a'. Only the ones with Dual ORPorts 'd'. Do Nothing 'n'  (a/d/n) " yn

case $yn in 
        a ) perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  $ipaddress1 file2 > /var/tmp/remove ; 
              cd /var/tmp ;
              for i in `cat remove` ;
              do
              ipset del ddos-$ipaddress1 $i
              done;
              perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  $ipaddress2 file2 > /var/tmp/remove2 ; 
              cd /var/tmp ;
              for i in `cat remove2` ;
              do
              ipset del ddos-$ipaddress2 $i
              done;;
              
	d ) perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  $ipaddress1 dual-or > /var/tmp/dual ;
              cd /var/tmp ;
              for i in `cat dual` ;
              do
              ipset del ddos-$ipaddress1 $i
              done;
              perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  $ipaddress2 dual-or > /var/tmp/dual2 ;
              cd /var/tmp ;
              for i in `cat dual2` ;
              do
              ipset del ddos-$ipaddress2 $i
              done;;
            
	n ) echo exiting...;
	      exit;;

	* ) echo invalid response;
	      exit 1;;
esac
