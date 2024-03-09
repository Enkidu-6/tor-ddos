#!/bin/bash
# set -x
red='\033[0;31m'
green='\033[1;32m'
plain='\033[0m'
wget -O tor.tar.gz https://github.com/Enkidu-6/tor-ddos/archive/refs/tags/v7.0.1.tar.gz
mkdir tor
tar -xzf tor.tar.gz -C tor --strip-components 1
sleep 1
cd tor
chmod 0700 *.sh
check() {
FILE=$(find / -name ipv4.txt)
FILE2=$(find / -name ipv6.txt)
if [ -f "$FILE" ]; then
    echo -e ${green}"Looks like you may have used these scripts before."
    echo -e "You can upgrade to the new version and keep your block lists intact"
    read -p "Would you like to update your existing rules? <y/n> " prompt
    echo -e ${plain}
    case $prompt in
    [yY]*)
        echo -e ${green}"Great! This is what I found in your current IP files"${plain}
        echo -e "${white}$(cat $FILE) ${plain}\n"
        echo -e "${white}$(cat $FILE2) ${plain}\n"
        echo -e ${green}
        read -p "Are these values correct? <y/n> " response
        echo -e ${plain}
        case $response in
        [yY]*)
            ./update.sh
            ;;

        [nN]*)
            echo -e ${green} "Okay then, we start fresh" ${plain}
            ./start.sh
            ;;

        *)
            echo -e ${red}"Invalid Response"${plain}
            check
            ;;

        esac
        ;;

    [nN]*)
        echo -e ${green}"Okay. We'll start fresh."${plain}
        ./start.sh
        ;;

    *)
        echo -e ${red}"Invalid response"${plain}
        check
        ;;
    esac
else
    ./start.sh
fi
}
check