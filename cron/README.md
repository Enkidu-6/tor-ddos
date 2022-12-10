# cron scripts
The above files can be used for regular cron jobs:
**refresh-authorities.sh** must be run daily to ensure you will always have the most current IP list for authorities and snowflake in your allow-list

The rest are optional but running at least **remove-dual-or.sh** is recommended. You can run it once every 10 minutes or longer or shorter as you see fit. 
It removes relays that have two ORPorts from the block list and gives them the chance to make two more connections if they need to.

If you have two instances of Tor running yourself, then use both **remove-dual-or.sh** and **remove-dual-or2.sh**

**remove.sh** and **remove2.sh** can be used to remove all relays from the block list and that's not necessary in my view but I'd like to give people options.

**monitor.sh** was created as per request of one of the users and you're welcome to use it. It shows how many IP addresses you have in your block list at any given
time and how many of them are relays and it keeps a log of it for future reference. Can be run at any interval.
