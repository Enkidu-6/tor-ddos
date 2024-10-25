#!/bin/bash
# set -x
red='\033[0;31m'
green='\033[1;32m'
blue='\033[1;36m'
white='\033[1;37m'
plain='\033[0m'

os() {

   if [[ -f /etc/os-release ]]; then
      source /etc/os-release
      release=$ID
   elif [[ -f /usr/lib/os-release ]]; then
      source /usr/lib/os-release
      release=$ID
   else
      echo "Failed to check the system OS, please contact the author!" >&2
      exit 1
   fi

   echo "The OS release is: $release"

   if [[ "${release}" == "debian" ]] || [[ "${release}" == "ubuntu" ]]; then
      apt install -y conntrack ipset
      ./multi.sh
   else
      ./multi.sh
   fi
}

wrapup() {
   echo -e "\n${green}These are the values you entered: ${plain}\n"
   echo
   echo -e "${white}$(cat ipv4.txt) ${plain}"
   echo
   echo -e "${white}$(cat ipv6.txt) ${plain}"
   echo
   echo -e "${green}"
   read -p "Are these values correct? <y/n> " response
   echo -e "${plain}"
   case $response in
   [yY]*)
      os
      ;;

   [nN]*)
      echo -e ${green} "Okay then, we start again." ${plain}
      start
      ;;

   *)
      echo -e ${red}"Invalid option. Let's start again"${plain}
      sleep 1
      start
      ;;

   esac
}

start() {
   echo -e "\n${green}Please enter your IPv4 (e.g. 10.10.10.10):\n ${plain}"
   read IP
   echo -e "\n${green}Enter your ORPort or comma separated multiple ORPorts (e.g. 443,80,8080):\n ${plain}"
   read OR
   if [[ -f "ipv4.txt" ]]; then
      /bin/rm -r ipv4.txt
   fi
   IFS=","
   for v in $OR; do
      echo $IP:$v >>ipv4.txt
   done
   echo -e "${green}"
   read -p "Do you have an IPv6 address? <y/n> " prompt
   echo -e "${plain}"
   case $prompt in
   [yY]*)
      echo -e "\n${green}enter your IPv6:\n ${plain}"
      read IP6
      if [[ -f "ipv6.txt" ]]; then
         /bin/rm -r ipv6.txt
      fi
      for v in $OR; do
         echo [$IP6]:$v >>ipv6.txt
      done
      wrapup
      ;;

   [nN]*)
      echo >ipv6.txt
      wrapup
      ;;

   *)
      echo -e ${red}"You entered an invalid option. Let's start again."${plain}
      start
      ;;

   esac
}
start
