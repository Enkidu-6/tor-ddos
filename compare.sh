#!/bin/bash
# set -x
green='\033[1;32m'
blue='\033[1;36m'
white='\033[1;37m'
plain='\033[0m'

if [[ ! -e /var/tmp/file2 ]]; then
      curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/relays-v4.txt' >/var/tmp/file2
elif
      [[ $(find "/var/tmp/file2" -mmin +60 -print) ]]
then
      curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/relays-v4.txt' >/var/tmp/file2
fi

if [[ ! -e /var/tmp/multi ]]; then
      curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/above1-or.txt' >/var/tmp/multi
elif
      [[ $(find "/var/tmp/multi" -mmin +60 -print) ]]
then
      curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/above1-or.txt' >/var/tmp/multi
fi

for i in $(cat ipv4.txt | sed 's/:/-/'); do
      /usr/sbin/ipset -L tor-$i | awk '{print $1}' >/var/tmp/$i

      echo -e "${green}All Blocked Addresses in tor-$i:${white}"
      /usr/sbin/ipset -L tor-$i | grep 'Number' | awk '{ print $4 }'
      sleep 2
      echo -e "${green}All relays in tor-$i:${white}"
      perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/' /var/tmp/$i /var/tmp/file2
      echo -e "${green}Relays with multiple Tor instances in tor-$i:${white}"
      perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/' /var/tmp/$i /var/tmp/multi

      read -p "Remove All 'a'. Only the ones with multiple OR ports 'm'. Do Nothing 'n'  (a/m/n) " yn

      case $yn in
      a)
            perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/' /var/tmp/$i /var/tmp/file2 >/var/tmp/remove-$i
            for b in $(cat /var/tmp/remove-$i); do
                  /usr/sbin/ipset del tor-$i $b
            done
            ;;

      m)
            perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/' /var/tmp/$i /var/tmp/multi >/var/tmp/dual-$i
            for b in $(cat /var/tmp/dual-$i); do
                  /usr/sbin/ipset del tor-$i $b
            done
            ;;

      n)
            echo -e "Doing nothing, next list .... ${plain}"
            ;;

      *)
            echo -e "invalid response, next list ... ${plain}"
            ;;

      esac

      echo -e "${white}"
      read -p "Press Enter to continue" </dev/tty
      echo -e "${plain}"
done

for i in $(cat ipv4.txt | sed 's/:/-/'); do
      /bin/rm -r /var/tmp/$i /var/tmp/remove-$i /var/tmp/dual-$i 2>/dev/null
done
