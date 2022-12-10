# One Server, Multiple IP addresses
If you have a server with multiple addresses and running multiple TOR instances on the same server eg. Ansible-relayor, OutboundBindAddress, ... 
you can use **multi-addr.sh**. It applies the rules to two IP addresses at a time. You can change the IP addresses and run the script multiple times to apply the rules to all your IP addresses gradually and monitor the results as you go.

The above script is a work in progress and relies on your feedback as I don't have a similar setup to test it on. So please give feedback and suggestions if you decide
to use it. As is though, it can't harm your server and your system can be reversed to the original state immediately with a one line command and without the need to reboot or restart TOR.

Please note that when you run the script for the first time, it makes a backup of your original iptables rules and it can be used to reverse everything back to the original state without the need for a reboot. **You should keep a copy of it at another location as the second time you run the script, the original backup will be wiped out and replaced.** 

All the rules are wiped out after a reboot as well.
