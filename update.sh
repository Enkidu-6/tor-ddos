#!/bin/bash
# set -x
#Only to update from version 5.0.0 or above.
#List all your IP Addresses and their listening port in forms of 10.1.1.1:443 and [abcd:abcd::abcd]:443
#one line at a time in ipv4.txt and ipv6.txt respectively and place them in the same directory.
update () {
echo -e '#!/bin/bash\n# set -x'
echo -e 'iptables-save > /var/tmp/iptablesRules.v4\nip6tables-save > /var/tmp/ip6tablesRules.v4'
echo -e 'ipset save -f /var/tmp/ipset.full\nipset destroy\nsleep 1'
echo -e 'iptables -t mangle -F\nip6tables -t mangle -F\nsleep 1\nipset destroy'
echo -e 'sysctl net.ipv4.ip_local_port_range="1025 65000"\necho 20 > /proc/sys/net/ipv4/tcp_fin_timeout\nmodprobe xt_recent ip_list_tot=10000'
echo -e 'ipset restore -exist -f /var/tmp/ipset.full\nsleep 2'
echo "curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/authorities-v4.txt' | sed -e '1,3d' > /var/tmp/allow"
echo "curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/snowflake.txt' | sed -e '1,3d' >> /var/tmp/allow"
echo "curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/authorities-v6.txt' | sed -e '1,3d' > /var/tmp/allow6"
echo "curl -s 'https://raw.githubusercontent.com/Enkidu-6/tor-relay-lists/main/snowflake-v6.txt' | sed -e '1,3d' >> /var/tmp/allow6"
echo -e 'ipset flush allow-list\nipset flush allow-list6'
echo -e 'for i in `cat /var/tmp/allow` ;\ndo\nipset add -exist allow-list $i\ndone;'
echo "/bin/rm -r /var/tmp/allow"
echo -e 'for i in `cat /var/tmp/allow6` ;\ndo\nipset add -exist allow-list6 $i\ndone;'
echo "/bin/rm -r /var/tmp/allow6"

array=( `cat ipv4.txt | awk -F: '{ print $1 }'` )
array2=( `cat ipv4.txt | awk -F: '{ print $2 }'` )

for i in "${!array[@]}"; do
   printf "iptables -t mangle -I PREROUTING -p tcp --destination %s --dport %s -m set --match-set allow-list src -j ACCEPT\n" "${array[i]}" "${array2[i]}"
   printf "iptables -t mangle -A PREROUTING -p tcp --destination %s --destination-port %s -m recent --name ddos-%s-%s --set\n" "${array[i]}" "${array2[i]}" "${array[i]}" "${array2[i]}"
   printf "iptables -t mangle -A PREROUTING -p tcp --destination %s --destination-port %s -m connlimit --connlimit-mask 32 --connlimit-above 2 -j SET --add-set tor-%s-%s src\n" "${array[i]}" "${array2[i]}" "${array[i]}" "${array2[i]}"
   printf "iptables -t mangle -A PREROUTING -p tcp --destination %s --destination-port %s -m set --match-set tor-%s-%s src -j DROP\n" "${array[i]}" "${array2[i]}" "${array[i]}" "${array2[i]}"
   printf "iptables -t mangle -A PREROUTING -p tcp --syn --destination %s --destination-port %s -m hashlimit --hashlimit-name TOR-%s-%s --hashlimit-mode srcip --hashlimit-srcmask 32 --hashlimit-above 30/hour --hashlimit-burst 4 --hashlimit-htable-expire 120000 -j DROP\n" "${array[i]}" "${array2[i]}" "${array[i]}" "${array2[i]}" 
   printf "iptables -t mangle -A PREROUTING -p tcp --syn --destination %s --destination-port %s -m connlimit --connlimit-mask 32 --connlimit-above 2 -j DROP\n" "${array[i]}" "${array2[i]}"
   printf "iptables -t mangle -A PREROUTING -p tcp --destination %s --destination-port %s -j ACCEPT\n" "${array[i]}" "${array2[i]}"
done

ARRAY=( `cat ipv6.txt | sed 's/\[//g' | awk -F]: '{ print $1 }'` )
ARRAY2=( `cat ipv6.txt | awk -F]: '{ print $2 }'` )
ARRAY3=( `cat ipv6.txt | sed 's/\[//g' | awk -F]: '{ print $1 }' | sed 's/.*\(.\{8\}\)$/\1/'` )

for i in "${!ARRAY[@]}"; do
   printf "ip6tables -t mangle -I PREROUTING -p tcp --destination %s --dport %s -m set --match-set allow-list6 src -j ACCEPT\n" "${ARRAY[i]}" "${ARRAY2[i]}"
   printf "ip6tables -t mangle -A PREROUTING -p tcp --destination %s --destination-port %s -m recent --name ddos6-%s-%s --set\n" "${ARRAY[i]}" "${ARRAY2[i]}" "${ARRAY3[i]}" "${ARRAY2[i]}"
   printf "ip6tables -t mangle -A PREROUTING -p tcp --destination %s --destination-port %s -m connlimit --connlimit-mask 128 --connlimit-above 2 -j SET --add-set tor-%s-%s src\n" "${ARRAY[i]}" "${ARRAY2[i]}" "${ARRAY3[i]}" "${ARRAY2[i]}"
   printf "ip6tables -t mangle -A PREROUTING -p tcp --destination %s --destination-port %s -m set --match-set tor-%s-%s src -j DROP\n" "${ARRAY[i]}" "${ARRAY2[i]}" "${ARRAY3[i]}" "${ARRAY2[i]}"
   printf "ip6tables -t mangle -A PREROUTING -p tcp --syn --destination %s --destination-port %s -m hashlimit --hashlimit-name TOR6-%s-%s --hashlimit-mode srcip --hashlimit-srcmask 128 --hashlimit-above 30/hour --hashlimit-burst 4 --hashlimit-htable-expire 120000 -j DROP\n" "${ARRAY[i]}" "${ARRAY2[i]}" "${ARRAY3[i]}" "${ARRAY2[i]}"
   printf "ip6tables -t mangle -A PREROUTING -p tcp --syn --destination %s --destination-port %s -m connlimit --connlimit-mask 128 --connlimit-above 2 -j DROP\n" "${ARRAY[i]}" "${ARRAY2[i]}"
   printf "ip6tables -t mangle -A PREROUTING -p tcp --destination %s --destination-port %s -j ACCEPT\n" "${ARRAY[i]}" "${ARRAY2[i]}"
done
}
update > rules.sh
chmod 0700 rules.sh
./rules.sh
clear
echo -e "\033[1;37m                                 All done!" 
echo -e "Look for a file named rules.sh in this directory. It contains all the rules that were applied for your reference."
echo -e "From now on, as long as your IP addresses and ORPorts remain the same, you can run rules.sh instead of this script.\033[0m"
sleep 5
clear
echo -e "\033[1;37mThis script will list the rules in your mangle table in 5 seconds"
echo -e "You can check the rules and make sure they have been applied properly"
echo -e "Press control c to stop .......\033[0m"
sleep 7
iptables -S -t mangle
echo -e "\033[1;37mYou should check your ip6tables rules as well by typing ip6tables -S -t mangle"
echo -e "Exiting ....\033[0m"
