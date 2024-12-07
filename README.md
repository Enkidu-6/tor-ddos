# How to combat Tor Relay DDoS in 10 Seconds!

**It would be a good idea to follow [The main repository](https://github.com/Enkidu-6/tor-ddos) to be notified of any updates.**

# Update
If you're updating from a previous version, Use the same download command below. The script tries to determine if you've previously used these scripts by looking for ipv4.txt anywhere on your system and if it exists, it'll give you the choice to update or start fresh.

Please feel free to use the Repository's dicussion board if you need help or if you find a bug in the script.

[Release notes / changelog](https://github.com/Enkidu-6/tor-ddos/releases)

# TLDR Version

If you don't want to read the rest, all you need is to run the following command:
```sh
bash <(curl -Ls https://raw.githubusercontent.com/Enkidu-6/tor-ddos/main/download.sh)
```
**You must be root or use sudo to run the scripts**

The script will download all the files of the current release to $PWD/tor directory and will take you through the necessary steps and then applies the iptables rules for you. You don't have to do anything except answering a few questions and you're done. You need to know your IPV4 and IPV6 addresses and ORPorts.

If your OS is Ubuntu or Debian, the script will install conntrack utilities and ipset using apt as they don't come with them by default. New versions of Debian don't come with iptables or nft. For those OS versions iptables-nft will be installed using apt.

You need iptables, ipset and curl on your system. If the script fails, Type iptables -V ipset -V and curl -V to find out if you have them. Getting them is as simple as installing them from your System's native package manager.

**You need to run the above script only once** Don't use the above link again unless you plan to download the repo again and replace all your files. 

***After the first run, only use `multi.sh` after each reboot or `update.sh` If you don't want to reboot.***

**update.sh** will save and restore your ipset lists so you don't have to start from scratch. All IP addresses in the block list will remain intact and it will also refresh your allow lists and brings them up to date.


**That's it. You're good to go but please read on.**



**You should run a cron job with ***refresh-authorities.sh*** daily or once every few days to keep the list of IPs for tor authorities, snowflake servers, relays and multi-or relays up to date.**
From the same directory as the script, type:
```
(crontab -l ; echo "0 0 * * * $PWD/refresh-authorities.sh") | crontab -
```
If you've never set up a cron jub under that user, you'll get a message like this:

**no crontab for $USER** 

Don't worry, it'll create one. Don't run it again or you'll have a duplicate cron job. Type crontab -l to make sure it's there and the path is correct.

To see the IP addresses that are caught in the block list at any time you can type:

**ipset -L tor-ipaddress-port**


Run **compare.sh** file to simply check the block list against the list of all tor relays. It will display the IP addresses in the block list that are also a Tor relay. 

They stay in the list for a maximum of 12 hours and then released, unless they break the rules again.

Every time you run **compare.sh** you are given the option to either automatically remove all the relays or only the relays that are running multiple instances of Tor from the block list.

You can also remove those relays periodically from your block list using the simpler scripts suitable for a cron job mainly **remove.sh** and **remove-dual-or.sh** Use them as you see fit. You can play with the time interval until you find a number you're happy with. I personally never remove them.

**conntrack.sh** will check your conntrack table and gives you a count and shows you how many of your connections belong to relays. It will also list IP addresses that have more than 2 connections, sorted from the lowest number of connections to the highest.

**update.sh** can be used to update your rules from a lower version to a higher one or to simply refresh your rules in case you need to. It will also create a file named **update-rules.sh** which shows the rules in plain text for your review. It won't work after a reboot though. You must always run **multi.sh** or **rules.sh** after a reboot since all ipsets are removed upon reboot.

  
# tor-ddos The long version

I'm putting this together in response to some people who are looking for something simple that anyone regardless of their level of expertise can implement. Something that doesn't require a lot of time with no dependencies to install for majority of Linux systems. Something as simple as copy and paste if you want to.

# First step: Preparing your system for high number of connections:

There are a few tweaks you can do to make your system use the resources more efficiently. These techniques -and a lot more- are the techniques used for Web servers  dealing with very heavy loads.

Use your favorite text editor such as vi or nano as follows:

**nano /etc/sysctl.conf** 

**net.ipv4.tcp_fin_timeout = 20**

**net.ipv4.tcp_keepalive_time = 1200**

**net.ipv4.tcp_syncookies = 1**

**net.ipv4.tcp_tw_reuse = 1**

**net.ipv4.ip_local_port_range = 10000 65000**

**net.ipv4.tcp_max_syn_backlog = 8192**

**net.ipv4.tcp_max_tw_buckets = 5000** 


Some of these options may already be in your sysctl.conf so please remember, **edit but don't duplicate.**

Once you're done with adding and editing, save the file and type:

**/sbin/sysctl -p**

This will reload and enable the added settings.


# Explanation:

**net.ipv4.tcp_fin_timeout = 20**

If the socket is turned off by this request, this parameter determines how long it will remain in the FIN-WAIT-2 state. We set it to 20 seconds

**net.ipv4.tcp_keepalive_time = 1200**

The frequency at which the system sends keepalive messages. The default is 2 hours. changing it to 20 minutes.

**net.ipv4.tcp_syncookies = 1**

Turning Syn cookies on. When Syn waiting queue overflows, cookies are turned on so the system can continue processing them. The default value is 0 which basically means shutdown of the system.

**net.ipv4.tcp_tw_reuse = 1**

Enables reuse. Allowing TIME-WAIT sockets to be reused for a new TCP connection.

**net.ipv4.ip_local_port_range = 10000 65000**

The port range used for outgoing connections. The default is too small 32768 to 61000

**net.ipv4.tcp_max_syn_backlog = 8192**

This is the range of the SYN queue. The default is 1024. The larger queue length accommodates more network connections waiting to connect.

**net.ipv4.tcp_max_tw_buckets = 1200**

The maximum number of TIME_WAIT sockets maintained at the same time. If this number is exceeded, TIME_WAIT sockets will be cleared and a warning message is issued. The default is 180,000. This is a good way to reduce the number of TIME_WAIT sockets.


# iptables, What we should know:

Most Linux systems come with some sort of firewall such as firewalld, ufw, etc.. These firewalls are generally just a management front-end to the iptables with some additional commands of their own which are generally saved in a separate file, which means if you clear all the iptables rules, you'd still retain the rules you set in your firewall. Things like opening a port for example. However since we're going to clear all the iptables rules, don't just trust me, verify. Check your firewall after clearing the iptables to make sure the firewall rules are still there and if not, you'll need to add them again.

Practically all linux systems come with iptables or more recently with nftables which basically does the same and more. So you won't need to install iptables. Just type **iptables -V** . If you see a version, you have it. The same with ipset . An **ipset -v** will do the job. In some rare cases you may not have ipset installed and installing it is as simple as **apt-get ipset** or **yum install ipset** or...


Last but not least, in most examples of iptables rules that you see, you don't see a mention of a **table** or **-t** where our rules reside. When you don't mention a table, all rules will go to the default table which is **filter** and that's all good and fine and will do the job well. However, in order for the filter to work, you first have to have a connection. Accepting connections and then denying and cleaning up after them wastes a lot of resources.

Controlled lab tests clearly show that when using **iptables INPUT** with **filter** table, one CPU at 100% can process about 600,000 packets per second. The same exact CPU when **iptables PREROUTING** is used can process almost 1.7 Million packets per second. So since every bit of CPU counts, We're going to use **PREROUTING in the mangle table**. You can use **raw** table as well but raw table doesn't recognize a lot of filter rules but mangle understands raw rules, filter rules PREROUTING rules and more, which means we can use what we already know and are familiar with and add a few things too.


# Finally, the rules:

I have moved all the rules exclusively to mangle table and PREROUTING. They are ORPort specific, which means they will not affect your current rules in the filter table. Also, virtually any Linux flavor I know comes with an empty mangle table with universal ALLOW rules. It also makes reversing the effects of the rules easy as all you need to do is to clear the mangle table.

```
iptables-save > /var/tmp/iptablesRules.v4
iptables -t mangle -F
sysctl net.ipv4.ip_local_port_range="1025 65000"
echo 20 > /proc/sys/net/ipv4/tcp_fin_timeout
modprobe xt_recent ip_list_tot=10000
ipset create -exist allow-list hash:ip
ipset create tor-$ipaddress-$ORPort hash:ip family inet hashsize 4096 timeout 43200
iptables -t mangle -I PREROUTING -p tcp --destination $ipaddress --dport $ORPort -m set --match-set allow-list src -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort -m recent --name ddos-$ipaddress-$ORPort --set
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort -m set --match-set 4-or src -m connlimit --connlimit-mask 32 --connlimit-upto 2 -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort -m set --match-set dual-or src -m connlimit --connlimit-mask 32 --connlimit-upto 2 -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp --syn --destination $ipaddress --destination-port $ORPort -m connlimit --connlimit-mask 32 --connlimit-above 2 -j SET --add-set tor-$ipaddress-$ORPort src
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort -m connlimit --connlimit-mask 32 --connlimit-above 2 -j SET --add-set tor-$ipaddress-$ORPort src
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort -m set --match-set tor-$ipaddress-$ORPort src -j DROP
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort -m connlimit --connlimit-mask 32 --connlimit-above 1 -j DROP
iptables -t mangle -A PREROUTING -p tcp --destination $ipaddress --destination-port $ORPort -j ACCEPT
iptables -I INPUT -p tcp --destination $ipaddress --destination-port $ORPort -m set --match-set tor-$ipaddress-$ORPort src -j REJECT --reject-with tcp-reset
```

This is what the rules will do:

- Save the current rules so they can be reversed.
- Clear the mangle table.
- Increase the local port range. Reduce the fin timeout. Increase the size of ip_list_tot.
- Create an allow-list and list the IP addresses of Tor authorities and snowflake so they're free to do what they need.
- create a list of relays with more than two ORPorts
- Create a list of relays with two ORPorts
- Keep track of connections in a file named ddos-$ipaddress-$ORPort which will reside in /proc/net/xt_recent/
- Allow relays with more than two instances of Tor to have one connection per instance.
- Allow relays with two ORPorts to have up to two connections.
- Create an ipset to put the bad guys in.
- Put any ip address that attempts more than two concurrent requests in the list.
- Put any ip address that didn't make concurrent request but already has more than two connections in the list.
- Drop any future attempts from those in the list for 12 hours.
- Allow a maximum of one connection per IP to our ORPort for those not in our lists.
- Accept everyone else.
- Reject and close connections by IP addresses in the block list to clear their already established connections as soon as possible.

That's it. Just remember, anytime you reload your firewall, all these iptables rules are erased. At least I'm sure that's what happens with firewall-cmd --reload. Also a reboot will reset your iptables rules to default rules that came with your system.  Nevertheless we save the original rules so we can restore them with the following command if anything goes wrong:

```
iptables-restore < /var/tmp/iptablesRules.v4
ipset destroy
```

The ipsets will not remain intact upon reboot but won't be destroyed if you flush the iptables manually.

Thanks for running a relay,

Cheers.

**Inspired by @toralf iptables rules, adding a few twists.**
