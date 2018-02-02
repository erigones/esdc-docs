.. _debug_ipsec:


Debugging overlays and IPSec
****************************
One disadvantage of overlay networking is that it considerably increases the complexity of whole system. This consequently increases the number of places where things can go wrong. 

If an overlay network does not work, the best way to start is to use `ssh` to connect to nodes that host virtual machines that refuse to communicate. Then you can use several tools to find out what's going on.

    **ipadm show-addr** - this command will list you all configured IP addresses and respective NICs on a compute node (hypervisor). You need to find out which interface is used for overlay communication. The decision is simple - if the compute nodes are in the same :ref:`physical datacenter <cn_install_datacenter>`, they use admin interface. Otherwise they use external interface. Find appropriate interface name by looking at configured IP addresses.

    **snoop** - a network sniffer. Your swiss army knife to find out what packets are (not) flowing between the compute nodes in question.
Example: for sniffing packets on external interface between two nodes, run this (80.90.100.110 is a public address of the compute node on the other side):

    .. code-block:: bash

        [root@cn2 (MYDC-remote1) ~]# snoop -rd external0 host 80.90.100.110

    **ping** inside the virtual machines - try to generate some traffic inside overlay network to see some movement by *snoop*

    ``/opt/erigones/bin/debug/ipsec_*`` directory - contains various IPSec debug scripts (see XXX)

How things look like when using *snoop*:

* Overlay communication without IPSec, using UDP port 4790:

    .. code-block:: bash

        10.xx.yy.10 -> 10.xx.yy.11   UDP D=4790 S=49251 LEN=118
        10.xx.yy.11 -> 10.xx.yy.10   UDP D=4790 S=49251 LEN=118
        10.xx.yy.11 -> 10.xx.yy.10   UDP D=4790 S=49177 LEN=94
        10.xx.yy.10 -> 10.xx.yy.11   UDP D=4790 S=49251 LEN=118
        10.xx.yy.11 -> 10.xx.yy.10   UDP D=4790 S=49251 LEN=118
        10.xx.yy.10 -> 10.xx.yy.11   UDP D=4790 S=49252 LEN=62


* IPSec initial negotiation:

    .. code-block:: bash

         xx.yy.zz.10 -> xx.yy.zz.20  UDP D=500 S=500 LEN=232
         xx.yy.zz.20 -> xx.yy.zz.10  UDP D=500 S=500 LEN=160
         xx.yy.zz.10 -> xx.yy.zz.20  UDP D=500 S=500 LEN=372
         xx.yy.zz.20 -> xx.yy.zz.10  UDP D=500 S=500 LEN=300
         xx.yy.zz.10 -> xx.yy.zz.20  UDP D=500 S=500 LEN=100
         xx.yy.zz.20 -> xx.yy.zz.10  UDP D=500 S=500 LEN=205

* IPSec normal communication:

    .. code-block:: bash

        xx.yy.zz.10 -> xx.yy.zz.20  ESP SPI=0x11a183ba Replay=15027
        xx.yy.zz.20 -> xx.yy.zz.10  ESP SPI=0xfdc85734 Replay=86306
        xx.yy.zz.10 -> xx.yy.zz.20  ESP SPI=0x11a183ba Replay=15028
        xx.yy.zz.20 -> xx.yy.zz.10  ESP SPI=0xfdc85734 Replay=86307
        xx.yy.zz.10 -> xx.yy.zz.20  ESP SPI=0x11a183ba Replay=15029
        xx.yy.zz.20 -> xx.yy.zz.10  ESP SPI=0xfdc85734 Replay=86308
        xx.yy.zz.10 -> xx.yy.zz.20  ESP SPI=0x11a183ba Replay=15030
        xx.yy.zz.20 -> xx.yy.zz.10  ESP SPI=0xfdc85734 Replay=86309
        xx.yy.zz.10 -> xx.yy.zz.20  ESP SPI=0x11a183ba Replay=15031
        xx.yy.zz.10 -> xx.yy.zz.20  ESP SPI=0x11a183ba Replay=15032

* IPSec fragmented packets (bad thing, you need to lower the MTU in overlay rule definition):

    .. code-block:: bash

         xx.yy.zz.10 -> xx.yy.zz.20  ESP IP fragment ID=12388 Offset=0    MF=1 TOS=0x0 TTL=60
         xx.yy.zz.10 -> xx.yy.zz.20  ESP IP fragment ID=12388 Offset=1480 MF=0 TOS=0x0 TTL=60
         xx.yy.zz.10 -> xx.yy.zz.20  ESP IP fragment ID=12389 Offset=0    MF=1 TOS=0x0 TTL=60
         xx.yy.zz.10 -> xx.yy.zz.20  ESP IP fragment ID=12389 Offset=1480 MF=0 TOS=0x0 TTL=60
         xx.yy.zz.20 -> xx.yy.zz.10  ESP SPI=0x83c78776 Replay=30625
         xx.yy.zz.10 -> xx.yy.zz.20  ESP IP fragment ID=12390 Offset=0    MF=1 TOS=0x0 TTL=60
         xx.yy.zz.10 -> xx.yy.zz.20  ESP IP fragment ID=12390 Offset=1480 MF=0 TOS=0x0 TTL=60
         xx.yy.zz.10 -> xx.yy.zz.20  ESP IP fragment ID=12391 Offset=0    MF=1 TOS=0x0 TTL=60
         xx.yy.zz.10 -> xx.yy.zz.20  ESP IP fragment ID=12391 Offset=1480 MF=0 TOS=0x0 TTL=60
         xx.yy.zz.10 -> xx.yy.zz.20  ESP IP fragment ID=12392 Offset=0    MF=1 TOS=0x0 TTL=60
         xx.yy.zz.10 -> xx.yy.zz.20  ESP IP fragment ID=12392 Offset=1480 MF=0 TOS=0x0 TTL=60
         xx.yy.zz.10 -> xx.yy.zz.20  ESP SPI=0x7fc7028d Replay=207382
         xx.yy.zz.20 -> xx.yy.zz.10  ESP SPI=0x83c78776 Replay=30626
         xx.yy.zz.10 -> xx.yy.zz.20  ESP IP fragment ID=12394 Offset=0    MF=1 TOS=0x0 TTL=60
         xx.yy.zz.10 -> xx.yy.zz.20  ESP IP fragment ID=12394 Offset=1480 MF=0 TOS=0x0 TTL=60


When IPSec things are working correctly, you should see an XXXlink IPSec negotiation packets when virtual machines start to communicate for the first time (or a key renegotiation is needed). Immediately after that, you can see a normal XXXlink IPSec communication.

What can go wrong:
    * `you don't see any IPSec packets` - verify the snoop interface and parameters or verify that ipsec services are online (``svcs ipsecalgs ike policy``)
    * `you see only the negotiation phase packets from one IP but no packets from the other IP` - verify firewall, verify ipsec config (XXXlink ``esdc-overlay update``), try to flush association database on both hosts (see XXX)
    * `you see only the negotiation phase packets from both IPs but no normal IPSec ESP packets` - verify ipsec config (XXXlink ``esdc-overlay update``), try to flush association database on both hosts (see XXX)
    * `you see normal IPSec ESP packets but only from one host` - see print dropped packets, flush SADB
    * `you see normal IPSec ESP packets from both hosts` but the VMs don't communicate anyway - try to use network sniffer inside virtual machines on both nodes. There's a suspicion that one node is accepting packets but the other node is dropping them. If the suspicion is true, you should see the incoming and outgoing packets inside the one virtual machine but only outgoing packets inside the second virtual machine. Also XXXlink printing dropped packets will show some output. To solve the problem try to XXX flush association database or verify the XXX IPSec policy.

The following IPSec debug scripts can save you a lot of debugging time. They are ordered by priority in which you should go when searching for the answer.

IPSec debug scripts
===================

Print packets dropped by IPSec
------------------------------
To discover if IPSec is dropping any packets, you can use very handy `dtrace` script ``/opt/erigones/bin/debug/ipsec_print_dropped_packets.d``. It will tell you detailed info about the dropped packet including the reason why it was dropped.

A sample output:
    .. code-block:: bash

        IPsec dropped an inbound IPv4 packet.
        IPPROTO: 17    (1=ICMP, 6=TCP, 17=UDP; 50=ESP, see netinet/in.h)
        Src IP address: 80.1.65.242
        Dst IP address: 80.1.65.241
        Src port: 52678
        Dst port: 4789
        Packet len: 156
        Dropped by: IPsec SADB

There are several reasons for packet to drop (Dropped by):
    * **IPsec ESP** - the receiving host knows nothing about the sender. The most probable reason is that the receiver was restarted or has flushed its security association database and the sending host did not reach the key renew timeout. You can wait a few minutes or XXX clear the association database on the sender (to start renegotiation).
    * **IPsec SPD** - no matching IPSec security policy was found. Either the packet is forged or the security policy rules are incorrect.
    * **IPsec SADB** - no corresponding entry was found for the received packet. There are multiple reasons for this, e.g. corupted packet or misconfigured policy.


Turn on IPSec debug
-------------------
To make the things simpler, you can enable IPSec debug by running ``ipsec_logging_enable.sh`` and watching the logs: 

    .. code-block:: bash

        [root@cn01 (myDC) ~]# /opt/erigones/bin/debug/ipsec_logging_enable.sh
        [root@cn01 (myDC) ~]# tail -f /var/adm/messages /var/log/in.iked.log

To turn the logging off, run ``/opt/erigones/bin/debug/ipsec_logging_disable.sh``.


Run esdc-overlay update
-----------------------
To verify and (if needed) re-apply the configuration of IPSec (and overlays) on all compute nodes, you can run ``esdc-overlay update`` on the first compute node. For more info see XXX here.


Inspect/Flush IPSec SADB
------------------------
To see current contents of a security association database on a compute node, run ``/opt/erigones/bin/debug/ipsec_associations_print.sh``. The output is quite detailed but you can see there an IPSec status of all connected hosts. Please note that the other side does not necessarily have the same association status resulting in dropped packets. In this case it's worth examining the SADB also on the other compute node.

If you want to force a full renegotiation of IPSec connection, run

    .. code-block:: bash

        /opt/erigones/bin/debug/ipsec_associations_flush.sh

To flush all SADBs on all compute nodes, you can use ansible to make the things simpler. 
    .. code-block:: bash

        esdc-overlay update-ans-hosts
        cd /opt/erigones/ans
        # test ansible connect
        ansible all -a date
        # flush all SADBs everywhere
        ansible all -a /opt/erigones/bin/debug/ipsec_associations_flush.sh

IPSec services and config files
-------------------------------
There are 3 system services and 3 configuration files. To see status of IPSec services, run ``svcs ipsecalgs ike policy``.
Effective config files are located here:

    - /etc/inet/ike/config
    - /etc/inet/secret/ike.preshared
    - /etc/inet/ipsecinit.conf

But because the SmartOS does not persist the configuration by default (when booted from an USB stick), you can find the persistent configuration files here: ``/opt/custom/etc/ipsec/``. After changing the persistent configuration, reload IPSec by running ``/opt/custom/etc/rc-pre-network.d/020-ipsec-restore.sh refresh``.



