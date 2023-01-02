#!/bin/bash
# set -x
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

for i in `cat ipv4.txt | sed 's/:/-/'`;
do
/usr/sbin/ipset -L tor-$i | awk '{print $1}' > /var/tmp/$i

echo -e "\033[1;32mAll relays in tor-$i:\033[1;37m"
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  /var/tmp/$i /var/tmp/file2
echo -e "\033[1;32mRelays with two Tor instances in tor-$i:\033[1;37m"
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  /var/tmp/$i /var/tmp/dual-or

read -p "Remove All 'a'. Only the ones with Dual OR ports 'd'. Do Nothing 'n'  (a/d/n) " yn

case $yn in 
        a ) perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  /var/tmp/$i /var/tmp/file2 > /var/tmp/remove-$i ; 
              for b in `cat /var/tmp/remove-$i` ;
              do
              /usr/sbin/ipset del tor-$i $b
              done;;
              
	d ) perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  /var/tmp/$i /var/tmp/dual-or > /var/tmp/dual-$i ;
              for b in `cat /var/tmp/dual-$i` ;
              do
              /usr/sbin/ipset del tor-$i $b
              done;;
            
	n ) echo -e "Doing nothing, next list .... \033[0m";
	      ;;

	* ) echo -e "invalid response, next list ... \033[0m";             
	      ;;

esac

echo -e "\033[1;37m"
read -p "Press Enter to continue" </dev/tty
echo -e "\033[0m"
done;
for i in `cat ipv4.txt | sed 's/:/-/'`;
do
/bin/rm -r /var/tmp/$i /var/tmp/remove-$i /var/tmp/dual-$i 2> /dev/null
done;
