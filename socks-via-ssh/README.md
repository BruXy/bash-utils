Dynamic port forwarding with SSH
================================

Original blog post on
[bruxy.regnet.cz](http://bruxy.regnet.cz/web/linux/EN/socks-via-ssh/)

---

One of the super important function of SSH is a port forwarding. You can
use SSH access on some host to forward remote ports of specific host
locally or create a reverse tunnel to be able to access your host which
is hidden behing NAT. There are plenty of usages of port forwarding.

SSH also support *dynamic port forwarding via SOCKS proxy*. Benefits:

1.  No more \"Content is not available in your country\".
2.  No more \"Wait 120 minutes for another download\".
3.  No more \"The site is blocked\" because some government knows what
    is the best for you.
4.  No need for VPN (if you need it mainly for HTTP).
5.  No need for HTTP(S) proxy.

Only thing you need is an SSH access to the server in better IP range :)
SOCKS proxy is also supported by not only web browsers, but also some
FTP clients or BitTorrent clients have support of SOCKS.

CLI example
-----------

Let me show you an example, ssh to a server with option `-D 8080`. It
will create a tunnel on your localhost on port 8080, so be sure that no
other network service is binded to that port:

    $ ssh -D 8080 user@server

Now, leave this connection open and in different terminal try following.
First, just check if ssh process is binded to 8080 port:

    $ netstat -tnlp | grep :8080
    tcp        0      0 127.0.0.1:8080          0.0.0.0:*               LISTEN 9873/ssh        
    tcp6       0      0 ::1:8080                :::*                    LISTEN 9873/ssh        

Now check your public IP address, page
[ifconfig.co](http://ifconfig.co/) returns your public IP address:

    $ curl http://ifconfig.co

Now use SOCKs proxy:

    $ curl --socks5 localhost:8080 http://ifconfig.co

The second HTTP request will return a different IP address (the address
of your server). That request went via your SOCKS proxy.

After this short introduction enable SOCKS proxy in your HTML browser.
Firefox has its own settings in *Preferences → Advanced →
Network/Connection/Settings*, other browsers like Chrome will use system
wide settings. Find that settings in your system, but it looks always
very similar:

socks\_proxy.png

Enable your SOCKS proxy manually to `localhost:8080`. You can always
check [ifconfig.co](http://ifconfig.co/) before and after to see what is
your current IP address. After this all your HTTP requests will be
forwarded via SOCKS proxy and your IP address will be an address of the
server.

Many tunnels and simple proxy switching
---------------------------------------

If you are a guy like me, you probably have access to plenty of SSH
hosts and each of them could be used as a SOCKS proxy. If you need more
SSH accounts you can use Amazon Web Services to create very cheaply some
small machines just for your packet forwarding (in several availability
zones) or there are also some projects or friends with free shells, for
example at [freeshell.de](http://freeshell.de) you can get a shell
access for a post card :)

I have created a bash script which will enable tunnels on specific
hosts: `sstun`.

This early version needs to setup hosts in your `~/.ssh/config` and then
edit the array `SSH_HOSTS`. Be free to modify it for your needs, it also
uses `autossh` for monitoring and restarting of SSH sessions.

### Setup your \~/.ssh/config

To handle SSH connections easily create your config file and add item
for each host, the most important for SOCKS proxy is DynamicForward and
to be able to open more tunnels select different port number for each
host.

    Host work
        Hostname 198.51.100.123
        User bruxy
        Port 22123
        IdentityFile ~/.ssh/id_rsa_at_work
        IdentitiesOnly yes
        DynamicForward 8080

The example above has also more options for using different Port, User
and non-default RSA key. With this settings when I need to ssh to this
host I will just use `ssh work` instead of
`ssh -p 22123 -i ~/.ssh/id_rsa_at_work -D 8080 user@198.51.100.123` and
it works also with `scp` and probably with `rsync` with
`--rsh="ssh work"`.

### Enable tunnels

Script `sstun` has just few options: start, stop, status, restart and
help. Command `./sstun start` will start SSH sessions in background and
store process PIDs in lock file (`~/.sstun.run`), you can use `status`
to check all proxies, it will display what is your remote IP address via
each tunnel.

### Chrome plug-in for easy proxy switching

I am using [Proxy
SwitchySharp](https://chrome.google.com/webstore/detail/proxy-switchysharp/dpplabbmogkhghncfbfdeeokoefdjegm)
to manually set which tunnel I would like to use. It has also some
support and you can choose specific proxy automatically for different
sites.
