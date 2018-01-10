.. _network_interface:

Network Interface Configuration
*******************************

This section describes how to configure compute node networking and its persistence. *Danube Cloud* does not use physical network interfaces directly. Instead, it uses virtual network interfaces on top of it. However, this does not apply to the **admin** network interface.

.. seealso:: This section refers to the use of NIC tags. It is strongly recommended to read the :ref:`NIC tag management <network_nictag>` page before doing any network-related configuration on compute nodes.


How to add a network interface
##############################

* For creating a network interface in the global zone use the **dladm create-vnic** command:

    .. code-block:: bash

        [root@node01 ~] dladm create-vnic -v 30 -l bnx0 storage0
        [root@node01 ~] dladm show-vnic storage0
        LINK         OVER       SPEED MACADDRESS        MACADDRTYPE VID  ZONE
        storage0     aggr0      1000  2:8:20:23:2e:eb   random      30   --

* Create an L3 network interface in the global zone by using the **ipadm create-if** command:

    .. code-block:: bash

        [root@node01 ~] ipadm create-if storage0
        [root@node01 ~] ipadm show-if storage0
        IFNAME     STATE    CURRENT      PERSISTENT
        storage0   down     bm--------46 -46

* To configure a static IP address use the **ipadm create-addr** command:

    .. code-block:: bash

        [root@node01 ~] ipadm create-addr -t -T static -a 192.168.33.101/24 storage0/v4static
        [root@node01 ~] ipadm show-addr
        ADDROBJ           TYPE     STATE        ADDR
        lo0/v4            static   ok           127.0.0.1/8
        aggr0/_a          static   ok           172.17.0.101/24
        storage0/v4static static   ok           192.168.33.101/24
        lo0/v6            static   ok           ::1/128

    or obtain the IP address via DHCP:

        .. code-block:: bash

            [root@node01 ~] ipadm create-addr -t -T dhcp storage0/v4dhcp
            [root@node01 ~] ipadm show-addr
            ADDROBJ           TYPE     STATE        ADDR
            lo0/v4            static   ok           127.0.0.1/8
            storage0/v4dhcp   dhcp     ok           192.168.33.101/24
            lo0/v6            static   ok           ::1/128

* For IP address removal use the **ipadm delete-addr** command:

    .. code-block:: bash

        [root@node01 ~] ipadm delete-addr storage0/v4
        [root@node01 ~] ipadm show-addr
        ADDROBJ           TYPE     STATE        ADDR
        lo0/v4            static   ok           127.0.0.1/8
        lo0/v6            static   ok           ::1/128

* For IP address deactivation use the **ipadm disable-addr** command:

    .. code-block:: bash

        [root@node01 ~] ipadm disable-addr -t storage0/v4static
        [root@node01 ~] ipadm show-addr
        ADDROBJ           TYPE     STATE        ADDR
        lo0/v4            static   ok           127.0.0.1/8
        aggr0/_a          static   ok           172.17.0.101/24
        lo0/v6            static   ok           ::1/128
        storage0/v4static static   disabled     192.168.33.101/24

* Use the **dladm delete-if** command for complete removal of an L3 interface from the compute node. For complete removal of a virtual network interface use the **dladm delete-vnic** command.

    .. code-block:: bash

        [root@node01 ~] ipadm delete-if storage0
        [root@node01 ~] ipadm show-if storage0
        ipadm: Could not get interface(s): Interface does not exist
        [root@node01 ~] ipadm show-addr
        ADDROBJ           TYPE     STATE        ADDR
        lo0/v4            static   ok           127.0.0.1/8
        bnx0/_a           static   ok           172.17.0.101/24
        lo0/v6            static   ok           ::1/128

        [root@node01 ~] dladm delete-vnic storage0
        [root@node01 ~] dladm show-vnic storage0
        dladm: invalid vnic name 'storage0': object not found


How to add a persistent network interface
#########################################

1. Find out the MAC address of the physical network interface:

    .. code-block:: bash

        [root@node01 ~] dladm show-phys -m
        LINK         SLOT     ADDRESS            INUSE CLIENT
        bnx0         primary  e4:1f:13:b3:ff:38  yes  bnx0
        bnx1         primary  e4:1f:13:b3:ff:39  yes  bnx1

2. The configuration file located at ``/usbkey/config`` has to be modified in order to add the network interface persistently. The configuration directive is in the form ``<nic_tag><index>_``, where ``nic_tag`` specifies a NIC tag of the physical network interface and ``index`` determines the order of the virtual network interface. The following attributes can be configured for every network interface:

    - ``<nic_tag><index>_ip`` - IP address or ``'dhcp'``
    - ``<nic_tag><index>_netmask`` - network mask or ``'...'``
    - ``<nic_tag><index>_gateway`` - IP address of the gateway
    - ``<nic_tag><index>_vlan_id`` - VLAN ID
    - ``<nic_tag><index>_mac`` - MAC address (best used in conjunction with DHCP)
    - ``<nic_tag><index>_mtu`` - MTU size

    .. note:: The **ip** and **netmask** directives are mandatory.

    The following lines can be used for static IP address configuration:

        .. code-block:: bash

            # 'storage' network is on bnx0
            storage_nic=e4:1f:13:b3:ff:38

            storage0_ip=192.168.33.101
            storage0_netmask=255.255.255.0
            storage0_gateway=192.168.33.1
            storage0_vlan_id=30

    or when using DHCP to configure the IP address:

        .. code-block:: bash

            # 'storage' network is on bnx0
            storage_nic=e4:1f:13:b3:ff:38

            storage0_ip=dhcp
            storage0_netmask=...
            storage0_vlan_id=30
            storage0_mac=02:02:02:02:02:02


        .. note:: It is a good practice to configure the MAC address explicitly if DHCP is used for IP address configuration. If the MAC address is not configured, the IP address on the interface may be different after every reboot. This can cause problems with compute node not having the same IP address as it had before the reboot. This problem will happen only if the DHCP server is configured to assign IP addresses based on client's MAC address.

3. Reboot the compute node after editing the network configuration or use the **dladm** and **ipadm** commands for imminent configuration.
