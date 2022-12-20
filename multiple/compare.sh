#!/bin/bash
# set -x
#Change the IP Addresses to your own
ipaddress1=10.1.1.2
ipaddress2=10.1.1.3
/usr/sbin/ipset -L tor-$ipaddress1 | awk '{print $1}' > /var/tmp/$ipaddress1
/usr/sbin/ipset -L tor-$ipaddress2 | awk '{print $1}' > /var/tmp/$ipaddress2
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
echo -e "\033[1;32mAll relays in Block list $ipaddress1:\033[1;37m"
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  $ipaddress1 file2
echo -e "\033[1;32mAll relays in Block list $ipaddress2:\033[1;37m"
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  $ipaddress2 file2
echo -e "\033[1;32mRelays with two Tor instances in Block list $ipaddress1:\033[1;37m"
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  $ipaddress1 dual-or
echo -e "\033[1;32mRelays with two Tor instances in Block list $ipaddress2:\033[1;37m"
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  $ipaddress2 dual-or

read -p "Remove All 'a'. Only the ones with Dual ORPorts 'd'. Do Nothing 'n'  (a/d/n) " yn

case $yn in 
        a ) perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  $ipaddress1 file2 > /var/tmp/remove ; 
              cd /var/tmp ;
              for i in `cat remove` ;
              do
              /usr/sbin/ipset del tor-$ipaddress1 $i
              done;
              perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  $ipaddress2 file2 > /var/tmp/remove2 ; 
              cd /var/tmp ;
              for i in `cat remove2` ;
              do
              /usr/sbin/ipset del tor-$ipaddress2 $i
              done;;
              
	d ) perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  $ipaddress1 dual-or > /var/tmp/dual ;
              cd /var/tmp ;
              for i in `cat dual` ;
              do
              /usr/sbin/ipset del tor-$ipaddress1 $i
              done;
              perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  $ipaddress2 dual-or > /var/tmp/dual2 ;
              cd /var/tmp ;
              for i in `cat dual2` ;
              do
              /usr/sbin/ipset del tor-$ipaddress2 $i
              done;;
            
	n ) echo -e "exiting.... \033[0m";
	      exit;;

	* ) echo -e "invalid response \033[0m";
	      exit 1;;
esac
echo -e "\033[0m"
