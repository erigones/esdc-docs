Network Troubleshooting
***********************

How to display status of network interfaces
###########################################

.. code-block:: bash

    [root@headnode (mydc) ~] dladm show-phys
    LINK         MEDIA                STATE      SPEED  DUPLEX    DEVICE
    bnx0         Ethernet             up         1000   full      bnx0
    bnx1         Ethernet             up         1000   full      bnx1


How to display network interface MAC addresses
##############################################

.. code-block:: bash

    [root@headnode (mydc) ~] dladm show-phys -m
    LINK         SLOT     ADDRESS            INUSE CLIENT
    bnx0         primary  0:26:b9:53:27:58   yes  aggr0-bnx0
    bnx1         primary  0:26:b9:53:27:58   yes  aggr0-bnx1

How to display a list of link aggregations
##########################################

.. code-block:: bash

    [root@headnode (mydc ~] dladm show-aggr
    LINK            POLICY   ADDRPOLICY           LACPACTIVITY  LACPTIMER   FLAGS
    aggr0           L4       auto                 active        short       -----
    aggr1           L4       auto                 active        short       -----

How to display extended information about link aggregations
###########################################################

.. code-block:: bash

    [root@headnode (mydc ~] dladm show-aggr -x
    LINK        PORT           SPEED DUPLEX   STATE     ADDRESS            PORTSTATE
    aggr0       --             1000Mb full    up        40:f2:e9:8:e5:ac   --
               igb0           1000Mb full    up        40:f2:e9:8:e5:ac   attached
               igb1           1000Mb full    up        40:f2:e9:8:e5:ad   attached
    aggr1       --             1000Mb full    up        40:f2:e9:8:e5:ae   --
               igb2           1000Mb full    up        40:f2:e9:8:e5:ae   attached
               igb3           1000Mb full    up        40:f2:e9:8:e5:af   attached

How to display virtual network interfaces
#########################################

.. code-block:: bash

    [root@headnode (mydc) ~] dladm show-vnic
    LINK         OVER       SPEED MACADDRESS        MACADDRTYPE VID  ZONE
    net0         aggr0      0     72:96:a1:3d:e9:87 fixed       0    a28faa4d-d0ee-4593-938a-f0d062022b02
    net0         aggr0      0     b2:aa:d8:da:6d:4b fixed       0    f7860689-c435-4964-9f7d-2d2d70cfe389


How to display network traffic statistics in real-time
######################################################

.. code-block:: bash

    [root@headnode (mydc) ~] dladm show-link -S -i 1
    Link          iKb/s     oKb/s     iPk/s     oPk/s      %Util
    igb0          94.36    131.72    116.31     63.62       0.02
    igb1          91.96    317.66     77.54     95.43       0.04
    igb2          39.54    303.79     40.76     53.68       0.04
    igb3          92.60     27.19    107.36     28.83       0.01
    aggr0        186.31    450.06    194.83    160.04       0.07
    aggr1        132.13    330.95    148.11     82.51       0.05

* Link - Link name.
* iKb/s - The amount of incoming network traffic in KB/s.
* iPk/s - The amount of incoming packets.
* oKb/s - The amount of outgoing network traffic in KB/s.
* oPk/s - The amount of outgoing packets.
* %Util - Link utilization percentage.

How to capture network traffic
##############################

It is possible to capture traffic of zones and VMs with the outside world in the global zone. On this network interface, we will see the network traffic separated into VLANs. Traffic capture options can be specified by using various filters. The list of supported filters is located in the ``snoop(1M)`` man page.

.. code-block:: bash

    [root@headnode (mydc) ~] snoop -rd aggr0
    VLAN#5: 1.1.1.1 -> 2.2.2.2  DNS C example.com. Internet Addr ?
    VLAN#1401: 3.3.3.3 -> 4.4.4.4 TCP D=50718 S=3389 Push Ack=3566272237 Seq=3060367199 Len=53 Win=255
    VLAN#1401: 3.3.3.3 -> 4.4.4.4 TCP D=50389 S=3389 Ack=1994047464 Seq=3163671434 Len=1448 Win=256 Options=<nop,nop,tstamp 146343107 422995562>
    VLAN#1401: 3.3.3.3 -> 4.4.4.4 TCP D=50389 S=3389 Push Ack=1994047464 Seq=3163672882 Len=220 Win=256 Options=<nop,nop,tstamp 146343107 422995562>
    VLAN#1401: 4.4.4.4 -> 3.3.3.3 TCP D=3389 S=50389 Ack=3163673102 Seq=1994047464 Len=0 Win=4043 Options=<nop,nop,tstamp 422995613 146343107>
    ...

How to display zone network traffic
###################################

.. code-block:: bash

    [root@headnode (mydc) ~] snoop -rd net0 -z 76a321f5-1c8b-4b9e-8a0c-3d8f1f629e2a
    Using device net0 (promiscuous mode)
    1.1.1.1 -> (broadcast)  ARP C Who is 2.2.2.2, 2.2.2.2 ?
    1.1.1.1 -> 224.0.0.102  UDP D=1985 S=1985 LEN=80
    1.1.1.1 -> 3.3.3.3 SMTP C port=38081
    1.1.1.1 -> 3.3.3.3 SMTP C port=38081
    4.4.4.4 -> 1.1.1.1 SMTP R port=55579
    ...

