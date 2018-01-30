.. _network_nictag:

Overlay networking
******************

Network overlays in SmartOS and Danube Cloud are concept of encapsulating network traffic from virtual machines using the VXLAN technology. In SmartOS, overlays are a way of extending usable number of separate :ref:`virtual networks <network_virtual>` (e.g. one overlay per customer).

Danube Cloud extends this concept by adding IPSec VPN mesh to secure the (by default unencrypted) VXLAN packets, This allows to securely strech :ref:`virtual networks <network_virtual>` over the internet without the need of dedicated interconnects between multiple datacenters. Direct advantage of this approach is a possibility of creating remote compute nodes that are managed by the same Danube Cloud management interface regardless of their location on the internet.

In other words, Danube Cloud can create geographically spread transparent L2 networks which can be used by virtual machines to communicate as if they all were connected into a single local switch.

.. seealso:: This page explains concepts of overlay networking in Danube Cloud. Setting up all parts of overlay networs manually is possible but quite time consuming. That's why we have created an ``esdc-overlay`` command that automates creating and managing of overlay rules, admin overlays and firewalling. See :ref:`overlays automation XXX <howto/overlays-automation>`.

Extending number of virtual networks
====================================
In single physical datacenter, you can use overlays to extend number of networks. In this case you don't need IPSec because all communication occurs only in your own network backend.
Inside each overlay, you can define additional VLANs. Therefore it is a common practice to delegate one overlay (or more) to each :ref:`virtual datacenter (vDC) <dcs>` (e.g. various customers, environments, departments, etc) and admin of this virtual datacenter can create custom :ref:`virtual networks <network_virtual>` over VLANs as needed.

How many virtual networks can I have?
-------------------------------------
- **Without overlays**: 4096 (you need to have a switch with VLANs support)
- **With overlays**: 16 milions (no need for VLAN support on switches)


Stretching Danube Cloud over the internet
=========================================
Usually the compute nodes in one physical datacenter/rack are interconnected using an internal (admin) network. The Danube Cloud management daemon (erigonesd) on each compute node is connected to the management server via this admin network.

Danube Cloud from version v3.0.0 allows installing also remote compute nodes. A remote compute node can be located in geographicaly distant datacenter and does not need to be directly connected to the admin network. Erigonesd on such compute node connects to the management server using the internet. Admin network is not needed in this case.

Instead of communicating over admin network, the remote nodes use:
    * secure TCP connection for command channel,
    * overlay networking with IPSec to create :ref:`virtual networks <network_virtual>` that are stretched across the globe
      
From the virtual machines' perspective, the network based on overlays is fully transparent and it appears as if the VMs were connected into a single local switch regardless their real physical location.

How can I delegate overlays (and VLANs) administration?
-------------------------------------------------------
There are two related parameters in each :ref:`virtual datacenter's <dcs>` configuration:
  * *VMS_NET_VXLAN_ALLOWED* - list/range of allowed VXLAN numbers that can be created by a :ref:`vDC <dcs>` admin
  * *VMS_NET_VLAN_ALLOWED* - list/range of allowed VLAN numbers that can be created by a :ref:`vDC <dcs>` admin

Note that VLANs can be created on top of the overlays.


Overlay rules vs overlays vs vNICs
==================================
In short: *overlay rule > overlay > vNIC*

- vNICs of virtual machines are created on top of the overlays
- overlays are created according to overlay rules
- overlay rules are "templates" how to create overlays
- you need to add an VXLAN number to create overlay from a overlay rule
- overlays are using UDP VXLAN packets to encapsulate traffic
- overlays/VXLANs require configured and working underlying physical network links (plain IP connectivity)
- overlays in Danube Cloud work over **admin** network (**admin** or **admin0** NIC) or over the internet (**external0** NIC)
- there can be multiple overlay rules defined (each on a different UDP port number)
- there is a virtual ARP table created per overlay rule (``files/config`` parameter)
- the virtual ARP table is managed by Danube Cloud

How overlays are created
-------------------------
.. note:: For more info about creating the overlays, please see Danube Cloud wiki https://github.com/erigones/esdc-ce/wiki/SmartOS-Overlays

An overlay can be created manually using the ``dladm`` command. The following command creates overlay with VXLAN number *123* listening on UDP port *4789*:

.. code-block:: bash

    dladm create-overlay -e vxlan -p vxlan/listen_ip=192.168.100.100,vxlan/listen_port=4789 -s files -p files/config=/opt/custom/networking/my_overlay.json -p mtu=1400 -v 123 myoverlay123

This overlay however cannot be directly used by virtual machines. Network overlays are created automatically when first needed by ``vmadm`` command according to overlay rules. The overlay rule can look like this (in ``/usbkey/config``):

.. code-block:: bash

    overlay_rule_myoverlay="-e vxlan -p vxlan/listen_ip=192.168.100.100,vxlan/listen_port=4789 -s files -p files/config=/opt/custom/networking/my_overlay.json -p mtu=1400"

You can see that overlay rule is the same ``dladm`` parameter string without the ``-v`` parameter. The ``-v`` parameter will be added dynamically when the overlay is created (and the VXLAN number is appended to *overlay rule* name to create the *overlay name*).

After making changes to overlay rules in ``/usbkey/config``, you must either reboot the compute node or refresh the networking (``svcadm refresh network/virtual``) and refresh the compute node's information in Danube Cloud GUI/API.

The file ``files/config`` parameter points to a file containing an ARP routing table for all virtual machines created over the respective overlay rule. Danube Cloud takes care of updating this file automatically after the overlay rule is discovered on a compute node (after node restart of after refreshing node info in GUI/API).


Maximum packet length when using overlays
=========================================
A default MTU in SmartOS overlay networks is 1400.

There are several factors that make the overlay-encapsulated packet larger:
    * VXLAN header - encapsulates packet from virtual network into an UDP packet
    * VLAN header - additional VLAN header inside of the VXLAN packet
    * IPSec header - adds ESP header with encryption info

For these reasons the MTU of overlay vNICs is by default lowered from 1500 to 1400 bytes. If you are able to change the MTU on all the underlying physical switch infrastructure, we recommend increasing the MTU to 1800 bytes. Then you can set MTU at overlay rule definition to 1500.

However this is not possible if you have a remote compute node. Public internet infrastructure most probably doesn't allow higher MTUs. In this case you need to keep the MTU at 1400 or sometimes even lower (see Troubleshooting IPSec in Danube Cloud).

Admin overlay as a virtual admin network
========================================
The management daemon (erigonesd) on a remote compute node connects to a management server directly using the internet (instead of using the admin network). This allows basic management of a remote compute node. But there are other management services that need to be reachable from a remote compute node, e.g. connection to image server, to monitoring server, DNS, virtual machine migrations, etc. For this reason, you have to configure an overlay network dedicated to internal services.

Requirements for admin overlay:
    * It must be configured on all compute nodes
    * Each compute node must have a vNIC connected into this overlay
    * Each `adminoverlay` vNIC must have an IP address from the same subnet (you can choose a subnet; the IP address is used for connecting to management services).
      
Recommended naming and parameters:
    * Overlay rule: ``adminoverlay``
    * Overlay name: ``adminoverlay2``
    * VXLAN number: ``2``
    * VLAN number: ``2``
    * vNIC name: ``adminoverlay_0``
    * Adminoverlay subnet: a random range from 10.x.x.x/24
    * vNIC MAC: a random unused MAC address (it should not change on reboots)

A sample ``/usbkey/config`` entry:

    .. code-block:: bash

        overlay_rule_adminoverlay="-e vxlan -p vxlan/listen_ip=0.0.0.0 -p vxlan/listen_port=4793 -s files -p files/config=/opt/custom/networking/adminoverlay_overlay.json -p mtu=1300"
        adminoverlay_0_vxlan_id="2"
        adminoverlay_0_vlan_id="2"
        adminoverlay_0_ip="10.44.44.13"
        adminoverlay_0_netmask="255.255.255.0"
        adminoverlay_0_mac="00:e5:dc:d5:d4:cf"

.. note:: Detailed instructions on how to create `adminoverlay` overlay rule can be found in XXXX Overlays Automation section.

Requirements for overlays
=========================
If you use one or more remote compute nodes, you must have the following on ALL compute nodes regardless of their location:
    * ALL compute nodes need to have ``external`` NIC tag configured
    * ALL compute nodes need to have a public IPv4 address on the external interface that is reachable from the internet
    * ALL compute nodes need to have a default route set on external interface
    * Each remote location must have a different name of :ref:`physical datacenter <cn_install_datacenter>`

The reason for mandatory public IP addresses is because compute nodes are interconnected to a mesh network, sending overlay packets directly to the compute node that hosts the destination virtual machine (according to a virtual ARP routing table in ``files/config`` file).

.. warning:: Setting :ref:`physical datacenter <cn_install_datacenter>` name correctly during compute node installation is very important for overlay routing to work correctly. If your compute nodes can reach each other using the `admin` network, they need to have the same :ref:`physical datacenter <cn_install_datacenter>` name (so they don't need to use `IPSec` and they will communicate using the `admin` network). If the compute nodes cannot reach each other using the admin network, they *must* have a different :ref:`physical datacenter <cn_install_datacenter>` name.

In other words:
    * *If* sender's :ref:`PDC <cn_install_datacenter>` name == receiver's :ref:`PDC <cn_install_datacenter>` name **->** no IPSec and send overlay packets via `admin` network
    * *If* sender's :ref:`PDC <cn_install_datacenter>` name != receiver's :ref:`PDC <cn_install_datacenter>` name **->** apply IPSec and send overlay packets via the `external` interface, directly to an `external` IP of the destination compute node

Recommendations for overlays
============================
- It is recommended to create a separate overlay rule for user traffic (so the virtual ARP table is not shared with `adminoverlay`)
- If possible, configure your network switches to allow larger MTU (if not using remote compute nodes)
- Configure firewall on external interface of each compute node

Configuring a firewall on each compute node
===========================================
As each compute node has a public IP address, it is recommended to protect this interface from potential attackers. Additionally - to prevent from any IPSec misconfiguration or packet forgery - you may want to drop all overlay/VXLAN packets on ``external0`` interface that are not protected by IPSec.

To edit `ipfilter` configuration permanently, edit this file ``/var/fw/ipf.conf`` and then reload `ipfilter` by running ``svcadm refresh ipfilter``.

A sample `ipfilter` configuration:

    .. code-block:: bash

        # block outgoing unencrypted overlay traffic on external interface
        #   for two configured overlay rules (UDP ports 4790 and 4793)
        block out log quick on external0 proto udp from any to any port = 4790
        block out log quick on external0 proto udp from any to any port = 4793
        # block all incoming unencrypted overlay traffic from internet
        block in log quick on external0 proto udp from any to any port = 4790
        block in log quick on external0 proto udp from any to any port = 4793
        # allow administrator access
        pass in quick on external0 from <my_office_subnet> to any keep state
        pass in quick on external0 from <my_home_subnet> to any keep state
        # allow other compute nodes
        pass in quick on external0 from <other_compute_nodes_subnet> to any keep state
        pass in quick on external0 from <remote_compute_nodes_subnet> to any keep state
        # allow all other outgoing traffic
        pass out quick on external0 all keep state
        # block everything else
        block in quick on external0 all

Remote compute node security
============================
The management daemon on each compute node uses SSL certificate fingerprint to verify that it connects to the right management server. It will refuse to connect (and send password) to any other server. IP address or hostname of the management server can be changed if necessary.

IPSec pre-shared keys generated by XXX ``esdc-overlay`` are unique for each pair of compute nodes. Therefore even discovering the IPSec key does not compromise the whole system, only the communication of two physical servers.

However: all compute nodes have their `ssh-rsa` keys exchanged, so any compute node can connect to any other compute node using ssh without password (it is needed for backups, VM migrations and other administrations tasks). Therefore you should not install your remote compute nodes in unsafe locations as they could be possibly used as an attack vector. Use firewalls and also physical security, monitor ssh logins and compute node reboots. Integrated Zabbix system is your good friend here.

Overlay debug tools
===================
One disadvantage of overlay networking is that it considerably increases the complexity of whole system. This consequently increases the number of places where things can go wrong.

If an overlay network does not work, the best way to start is to use `ssh` to connect to nodes that host virtual machines that refuse to communicate. Then you can use several tools to find out what's going on.


CO dalej:
- rem. compute node add
- networks stack overview - kde sa overlays nachadzaju
- security - cert fingerprint
- nevyhody
  - priepustnost IPSec
  - higher complexity (vxlan layer, IPSec, virtual routing tables)
  - MTU

