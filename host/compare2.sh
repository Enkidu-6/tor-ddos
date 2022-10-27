#!/bin/bash
# set -x
ipset -L tor2-ddos | awk '{print $1}' > /var/tmp/file3
ipset -L persec2 | awk '{print $1}' >> /var/tmp/file3
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/relays-v4.txt' > /var/tmp/file2
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/dual-or.txt' > /var/tmp/dual-or
cd /var/tmp
echo -e "\033[0;32mAll relays in Block list:\033[0m"
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  file3 file2
echo -e "\033[0;32mRelays with two Tor instances:\033[0m"
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  file3 dual-or

read -p "Remove All 'a'. Only the ones with Dual OR ports 'd'. Do Nothing 'n'  (a/d/n) " yn

case $yn in 
        a ) perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  file3 file2 > /var/tmp/remove2 ; 
              cd /var/tmp ;
              for i in `cat remove2` ;
              do
              ipset del tor2-ddos $i
              done;;
              
	d ) perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  file3 dual-or > /var/tmp/dual2 ;
              cd /var/tmp ;
              for i in `cat dual2` ;
              do
              ipset del tor2-ddos $i
              done;;
            
	n ) echo exiting...;
	      exit;;

	* ) echo invalid response;
	      exit 1;;
esac
