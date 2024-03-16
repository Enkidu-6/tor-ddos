#!/bin/bash
# set -x
red='\033[0;31m'
green='\033[1;32m'
white='\033[1;37m'
plain='\033[0m'
wget -O tor.tar.gz https://raw.githubusercontent.com/Enkidu-6/tor-ddos/main/src/tor.tar.gz
mkdir tor
tar -xzf tor.tar.gz -C tor
/bin/rm -r tor.tar.gz
sleep 1
cd tor
chmod 0700 *.sh
check() {
    FILE=$(find / -name ipv4.txt)
    FILE2=$(find / -name ipv6.txt)
    FILE3=$(find / -name "ipv*.txt")
    if [[ $(ls -l $FILE | wc -l) -gt 1 || $(ls -l $FILE2 | wc -l) -gt 1 ]]; then
        echo -e "${green}Looks like you may have used these scripts before.${plain}"
        echo -e "\n${green}However, it seems that you have more than one ipv4.txt on your system${plain}"
        echo -e "\n${white}"
        ls $FILE | nl
        cat $FILE | nl
        echo -e ""
        ls $FILE2 | nl
        cat $FILE2 | nl
        echo -e "${plain}"
        echo -e ""
        echo -e "${green}Please check the files and Keep only one copy of each ipv4.txt and ipv6.txt.${plain}"
        echo -e "${green}By chosing the number next to each file, it will be renamed with a .back extension${plain}"
        select f in $(ls $FILE3); do
            if [ -n "$f" ]; then
                mv $f $f.back
                check
                exit
            fi
        done
    fi
    if [ -f "$FILE" ]; then
        echo -e "${green}Looks like you may have used these scripts before.${plain}"
        echo -e "${green}You can now upgrade to the new version and keep your block lists intact."
        read -p "Would you like to update your existing rules? <y/n> " prompt
        echo -e ${plain}
        case $prompt in
        [yY]*)
            echo -e "\n${green}Great! This is what I found in your current IP files: ${plain}\n\n"
            echo -e "${white}$(cat $FILE) ${plain}\n"
            echo -e "${white}$(cat $FILE2) ${plain}\n"
            echo -e ${green}
            read -p "Are these values correct? <y/n> " response
            echo -e ${plain}
            case $response in
            [yY]*)
                cp $FILE ipv4.txt
                cp $FILE2 ipv6.txt
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
