# Update
**There are a few major revisions and bug fixes in the new version 3.0. Please update as soon as you're able to. All you need is to run the appropriate update file in the update directory. No reboot or restart of Tor is necessary and there will be zero downtime.** ***Don't forget to change the port number to your own ORPorts before running the scripts.*** **The update files can be used at any time to update to the newest version regardless of your previous version.**

# TLDR Version

If you don't want to read the rest and like majority of operators, you are simply running a relay with a single ORPort, just run **combined.sh**. Or you can run **iptables.sh** and **ip6tables.sh** individually if you like. They're a series of commands and iptables rules one after another. You can even copy the content and just paste them in the terminl. You must be root or run the script using sudo. ***It assumes your ORPort is 443. If you're listening on another port, change 443 to whatever port you're listening on before running the script*** otherwise all these rules will be useless to you.

So this is how it goes:

```
wget https://raw.githubusercontent.com/Enkidu-6/tor-ddos/main/combined.sh
```
```
chmod a+x combined.sh
```
***Edit the file and change the ORPort to your own.***
```
sudo ./combined.sh
```

That's it. You're good to go.

If you have two instances of Tor running on the same system with two ORPorts, use **combined-2or.sh** in the **dual-or** directory

Both versions of the scripts make a backup of your original iptables and ip6tables rules. You can restore the original rules by either simply rebooting or running the following commands:

```
iptables-restore < /var/tmp/iptablesRules.v4
ip6tables-restore < /var/tmp/ip6tablesRules.v4
ipset destroy

```

If you are running Tor on a VM and have access to the host e.g KVM, Proxmox, etc... you can run the iptables on the host and have all the packets filtered using the Host's resources before they are forwarded to the VM. This will allow your VM to use all the resources available to it for running Tor without spending any resources on filtering. In that case use **combined-host.sh** or **combined-2or-host.sh** respectively in the **host** directory.


To see how many IP addresses are caught in the block list at any time you can type:

**ipset -L tor-ddos**


Run **compare.sh** file to simply check the block list against the list of all tor relays. It will display the IP addresses in the block list that are also a tor relay. 

They stay in the list for a maximum of 12 hours and then released, unless they break the rules again.

Every time you run **compare.sh** you are given the option to either automatically remove all the relays or only the relays that are running two instances of Tor from the block list.

You can also remove those relays periodically from your block list using the simpler scripts suitable for a cron job in the **cron** directory. Use them as you see fit.

Type the following in terminal:

```
(crontab -l ; echo "*/1 * * * * /your_path_to/remove.sh") | crontab - 
```
It will check and remove all relays from your block list once a minute.

# tor-ddos The long version

I'm putting this together in response to some people who are looking for something simple that anyone regardless of their level of expertise can implement. Something that doesn't require a lot of time. No scripts, just mostly plain text and as simple as copy and paste if you want to.

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

I have moved all the rules exclusively to mangle table and PREROUTING. They are ORPort specific, which means they will not affect your current rules in the filter table. Also, virtually any Linux flavor I know comes with an empty mangle table with universal ALLOW rules.


```
iptables-save > /var/tmp/iptablesRules.v4

iptables -t mangle -F

```
The above commands will first save the original rules for backup and then clear the mangle table just to be sure
P.S.

This would be a good time to check your firewall and make sure your previous configurations are still there.
```
ipset create -exist allow-list hash:ip

ipset add -exist allow-list 128.31.0.39

ipset add -exist allow-list 131.188.40.189

ipset add -exist allow-list 154.35.175.225

ipset add -exist allow-list 171.25.193.9

ipset add -exist allow-list 193.23.244.244

ipset add -exist allow-list 199.58.81.140

ipset add -exist allow-list 204.13.164.118

ipset add -exist allow-list 45.66.33.45

ipset add -exist allow-list 66.111.2.131

ipset add -exist allow-list 86.59.21.38

ipset add -exist allow-list 193.187.88.42
```

We create an ipset and add the addresses of the tor authorities so we can whitelist them. The last IP is actually the address for the snowflake. In the recent version of the script we now do a relay search and pull the most recent IP addresses for the above servers to make sure we don't have a wrong IP address hardcoded into the script.

```
ipset create tor-ddos hash:ip family inet hashsize 4096 timeout 43200

```

Adding one more ipset for those who make too many connections. It expires in 12 hours.

```
sysctl net.ipv4.ip_local_port_range="10000 65000"

echo 20 > /proc/sys/net/ipv4/tcp_fin_timeout

modprobe xt_recent ip_list_tot=10000
```

Just in case you didn't want to edit your **sysctl.conf**. You should at least do these three lines which is why I'm including them in the scripts. The last one is important because when you are keeping track of connections, by default linux keeps track of 100 of them at most and then replaces them with new connections. We want to keep a longer list so we increase it to 10000.

***Please note that the following rules assume your Orport is 443. If you are listening on a different port replace 443 with your own.***

```
iptables -t mangle -I PREROUTING -p tcp -m set --match-set allow-list src -j ACCEPT

iptables -t mangle -A PREROUTING -p tcp --syn --destination-port $ORPort -m hashlimit --hashlimit-name TOR-$ORPort --hashlimit-mode srcip --hashlimit-srcmask 32 --hashlimit-above 1/minute --hashlimit-burst 5 --hashlimit-htable-expire 60000 -j DROP

iptables -t mangle -A PREROUTING -p tcp --destination-port 443 -m recent --name tor-ddos --set

iptables -t mangle -A PREROUTING -p tcp --destination-port 443 -m connlimit --connlimit-mask 32 --connlimit-above 4 -j SET --add-set tor-ddos src

iptables -t mangle -A PREROUTING -p tcp --syn --destination-port 443 -m connlimit --connlimit-mask 32 --connlimit-above 4 -j DROP

iptables -t mangle -A PREROUTING -p tcp -m set --match-set persec src -j DROP

iptables -t mangle -A PREROUTING -p tcp -m set --match-set tor-ddos src -j DROP

iptables -t mangle -A PREROUTING -p tcp --destination-port 443 -j ACCEPT
```

We let tor-authorities and snowflake do what they need to do.

We throttle the connections of abusive IP addresses to 1 per minute after letting the first 5 connection requests through. This will prevent your conntrack table to get flooded at a very high rate at once and gives your system time to process and add them to the block list gradually while they wait. It also, to a certain point, protect you from SYN flood attacks.

keep track of connections in a file named tor-ddos which will reside in /proc/net/xt_recent/

Add IP addresses that try to create more than 4 connections at a time to our ORPort to a list (tor-ddos).

Dropping any attempt to connect to ORPort if they already have 4, whether they are in the block list or not.

Dropping any attempt by those in our ddos list

Accept everyone else.


That's it. Just remember, anytime you reload your firewall, all these iptables rules are erased. At least I'm sure that's what happens with firewall-cmd --reload. Also a reboot will reset your iptables rules to default rules that came with your system.  Nevertheless we save the original rules so we can restore them with the following command if anything goes wrong:

```
iptables-restore < /var/tmp/iptablesRules.v4
ipset destroy
```

The ipsets may or may not remain intact upon reboot so if you decide to run the scripts again you may get errors. You must destroy the ipsets before running the script again.

You can also use **ipset-backup.sh** before each reboot and restore them with **ipset-restore.sh**

You can also run one of the **update** files - depending on your Tor setup -in the **update directory** to refresh everything. It saves your block lists so you don't have to start all over again but it clears your conntrack table and starts fresh.

Thanks for running a relay,

Cheers.

**Inspired by @toralf iptables rules, adding a few twists.**



