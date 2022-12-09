# One Server, Multiple IP addresses
If you have a server with multiple addresses and running multiple TOR instances on the same server eg. Ansible-relayor, OutboundBindAddress, ... you can use the above
script. It applies the rules to two IP addresses at a time. You can change the IP addresses and run the script multiple times to apply the rules to all your IP addresses
gradually.

The above script is a work in progress and relies on your feedback as I don't have a similar setup to test it on. So please give feedback and suggestions if you decide
to use it. As is though, it can't harm your server and your system can be reversed to the original state immediately with a one line command and without the need to reboot
or restart TOR.
