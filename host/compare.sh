#!/bin/bash
# set -x
ipset -L tor-ddos | awk '{print $1}' > /var/tmp/file1
if [[ ! -e /var/tmp/file2 ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/relays-v4.txt' > /var/tmp/file2
elif
[[ $(find "/var/tmp/file2" -mmin +60 -print) ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/relays-v4.txt' > /var/tmp/file2
fi
if [[ ! -e /var/tmp/dual-or ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/dual-or.txt' > /var/tmp/dual-or
elif
[[ $(find "/var/tmp/dual-or" -mmin +60 -print) ]]; then
curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/dual-or.txt' > /var/tmp/dual-or
fi
cd /var/tmp
echo -e "\033[1;32mAll relays in Block list:\033[1;37m"
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  file1 file2
echo -e "\033[1;32mRelays with two Tor instances:\033[1;37m"
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  file1 dual-or

read -p "Remove All 'a'. Only the ones with Dual OR ports 'd'. Do Nothing 'n'  (a/d/n) " yn

case $yn in 
        a ) perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  file1 file2 > /var/tmp/remove ; 
              cd /var/tmp ;
              for i in `cat remove` ;
              do
              ipset del tor-ddos $i
              done;;
              
	d ) perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  file1 dual-or > /var/tmp/dual ;
              cd /var/tmp ;
              for i in `cat dual` ;
              do
              ipset del tor-ddos $i
              done;;
            
	n ) echo -e "exiting.... \033[0m";
	      exit;;

	* ) echo -e "invalid response \033[0m";             
	      exit 1;;

esac
echo -e "\033[0m"
