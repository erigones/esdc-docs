.. _overlays:

Overlay networking
******************

Network overlays in SmartOS and *Danube Cloud* are a concept of encapsulating network traffic from virtual machines using the VXLAN technology. In SmartOS, overlays are a way of extending usable number of separate :ref:`virtual networks <network_virtual>` (e.g. one overlay per customer).

*Danube Cloud* extends this concept by adding IPSec VPN mesh to secure the (by default unencrypted) VXLAN packets, This allows to securely extend :ref:`virtual networks <network_virtual>` over the internet without the need of dedicated interconnects between multiple physical data centers. Direct advantage of this approach is a possibility of creating remote compute nodes that are managed by the same *Danube Cloud* management interface regardless of their location on the internet.

In other words, *Danube Cloud* can create geographically spread transparent L2 networks, which can be used by virtual servers to communicate as if they all were connected into a single local switch.

.. seealso:: This page explains concepts of overlay networking in *Danube Cloud*. Setting up all parts of overlay networks manually is possible but quite time consuming. That's why we have created an :ref:`esdc-overlay<esdc_overlay_cmd>` command that automates creating and managing of overlay rules, admin overlays and firewalls. See the :ref:`overlays automation guide<enable_overlays>`.


.. contents:: Table of Contents


Extending number of virtual networks
====================================
In a single physical data center, you can use overlays to extend the number of virtual networks. In this case you don't need IPSec because all communication occurs only in your own network backend.
Inside each overlay, you can define additional VLANs. Therefore it is a common practice to delegate one overlay (or more) to each :ref:`virtual data center<dcs>` (e.g. various customers, environments, departments, etc.) and an administrator of this virtual data center can create custom :ref:`virtual networks <network_virtual>` over VLANs as needed.

How many virtual networks can I have?
-------------------------------------
- **Without overlays**: usually 4096, depending on your network equipment (you need to have a switch with VLANs support).
- **With overlays**: 16 millions (no need for VLAN support on switches).

.. _overlays_extend_dc_over_inet:

Extending Danube Cloud over the internet
========================================
Usually, the compute nodes in one physical datacenter/rack are interconnected using an :ref:`internal (admin) network<network_nictag>`. The *Danube Cloud* management daemon (*erigonesd*) on each compute node is connected to the management server via this **admin** network.

*Danube Cloud* from version 3.0 allows installing also remote compute nodes. A remote compute node can be located in geographically distant data center and does not need to be directly connected to the **admin** network. The management daemon (*erigonesd*) on such compute node connects to the management server using the internet. The **admin** network is not needed in this case.

Instead of communicating over the **admin** network, the remote nodes use:
    * secure TCP connection for command channel,
    * overlay networking with IPSec to create :ref:`virtual networks <network_virtual>` that are stretched across the globe.
      
From the virtual machines' perspective, the network based on overlays is fully transparent and it appears as if the virtual servers were connected into a single local switch regardless of their real physical location.

How can I delegate overlays (and VLANs) administration?
-------------------------------------------------------
There are two related parameters in each :ref:`virtual data center's <dc_network_settings>` configuration:
    * **VMS_NET_VXLAN_ALLOWED** - list of allowed VXLAN IDs that can be created by a :ref:`DCAdmin<roles>`.
    * **VMS_NET_VLAN_ALLOWED** - list of allowed VLAN IDs that can be created by a :ref:`DCAdmin<roles>`.

Note that VLANs can be created on top of the overlays.


Overlay rules vs overlays vs vNICs
==================================
In short: *overlay rule > overlay > vNIC*

- vNICs of virtual servers are created on top of the overlays
- overlays are created according to overlay rules
- overlay rules are *"templates"* how to create overlays
- you need to add an VXLAN ID to create an overlay from an overlay rule
- overlays are using UDP VXLAN packets to encapsulate traffic
- overlays/VXLANs require a working underlying physical network links (plain IP connectivity)
- overlays in *Danube Cloud* work over the **admin** network (**admin** or **admin0** NIC) or over the internet (**external0** NIC)
- there can be multiple overlay rules defined (each on a different UDP port number)
- there is a virtual ARP table created per overlay rule (``files/config`` parameter)
- the virtual ARP table is managed by *Danube Cloud*

How overlays are created
========================
.. note:: For more info about creating the overlays, please see the *Danube Cloud* wiki https://github.com/erigones/esdc-ce/wiki/SmartOS-Overlays

An overlay can be created manually using the ``dladm`` command. The following command creates overlay with VXLAN number *123* listening on UDP port *4789*:

    .. code-block:: bash

        dladm create-overlay -e vxlan -p vxlan/listen_ip=192.168.100.100,vxlan/listen_port=4789 -s files -p files/config=/opt/custom/networking/my_overlay.json -p mtu=1400 -v 123 myoverlay123

This overlay however, cannot be directly used by virtual machines. Network overlays are created automatically when first needed by the ``vmadm`` command according to overlay rules. The overlay rule can look like this (in ``/usbkey/config``):

    .. code-block:: bash

        overlay_rule_myoverlay="-e vxlan -p vxlan/listen_ip=192.168.100.100,vxlan/listen_port=4789 -s files -p files/config=/opt/custom/networking/my_overlay.json -p mtu=1400"

You can see that overlay rule is the same ``dladm`` parameter string without the ``-v`` parameter. The ``-v`` parameter will be added dynamically when the overlay is created (and the VXLAN number is appended to overlay rule name to create a qualified overlay name).

After making changes to overlay rules in ``/usbkey/config``, you must either reboot the compute node or refresh the networking (``svcadm refresh network/virtual``) and refresh the compute node's information in *Danube Cloud* GUI/API.

The file ``files/config`` parameter points to a file containing an ARP routing table for all virtual machines created over the respective overlay rule. Danube Cloud takes care of updating this file automatically after the overlay rule is discovered on a compute node (after node restart or after refreshing node info in GUI/API).

About vxlan/listen_ip setting
=============================
When defining an overlay rule, the ``vxlan/listen_ip`` is mandatory. It defines a local IP address and consequently interface, which will be used by the kernel itself to listen for incoming VXLAN (= overlay) packets. It is possible to set it to a special value of ``0.0.0.0``, which tells the kernel to listen on all available interfaces on a defined UDP port. This is very useful to allow overlays to reach local compute nodes over the **admin** network and in the same time also over the internet to remote compute nodes.

But setting ``0.0.0.0`` has its drawbacks that you should be aware of. VXLAN packets are not signed or protected in any way so the receiver side cannot safely recognize the true sender of the VXLAN packet. If you don't protect your public interface, you are prone to a packet forgery.

The :ref:`esdc-overlay<esdc_overlay_cmd>` command will set up the protection for you in several ways:
    - by :ref:`setting up IPSec<esdc_overlay_create_adminoverlay>` to drop unknown or unencrypted VXLAN packets received on the **external0** interface,
    - by :ref:`setting up firewall rules<esdc_overlay_cmd_enable_fw>` on each compute node to drop incoming and outgoing unencrypted VXLAN packets on the **external0** interface (if for some reason the IPSec service fails and goes down).

But even with this protection in place, you may want to create some overlay rules with ``vxlan/listen_ip`` set to a single internal IP address of the compute node if the specified overlay rule does not expand to remote compute nodes.

Maximum packet length when using overlays
=========================================
The default MTU in SmartOS overlay networks is 1400.

There are several factors that make the overlay-encapsulated packet larger:
    * VXLAN header - encapsulates packet from virtual network into an UDP packet
    * VLAN header - additional VLAN header inside of the VXLAN packet
    * IPSec header - adds ESP header with encryption info

For these reasons the MTU of overlay vNICs is by default lowered from 1500 to 1400 bytes. If you are able to change the MTU on all the underlying physical network infrastructure, we recommend increasing the MTU to 1800 bytes. Then you can set MTU at overlay rule definition to 1500.

However, this is not possible if you have a remote compute node. Public internet infrastructure most probably doesn't allow higher MTUs. In this case you need to keep the MTU at 1400 or sometimes even lower (see :ref:`Troubleshooting IPSec<debug_ipsec>` in *Danube Cloud*).

.. _overlays_adminoverlay:

Admin overlay as a virtual admin network
========================================
The management daemon (*erigonesd*) on a remote compute node connects to a management server directly using the internet (instead of using the **admin** network). This allows basic management of a remote compute node. But there are other management services that need to be reachable from a remote compute node, e.g. connection to image server, to monitoring server, DNS, virtual machine migrations, etc. For this reason, you have to configure an overlay network dedicated to *Danube Cloud* *admin services*.

Requirements for admin overlay:
    * It must be configured on all compute nodes.
    * Each compute node must have a vNIC connected into this overlay.
    * Each `adminoverlay` vNIC must have an IP address from the same subnet (you can choose a subnet; the IP address is used for connecting to management services).
      
Recommended naming and parameters:
    * Overlay rule: ``adminoverlay``
    * Overlay name: ``adminoverlay2``
    * VXLAN number: ``2``
    * VLAN number: ``2``
    * vNIC name: ``adminoverlay_0``
    * `Adminoverlay` subnet: a random range from 10.x.x.x/24
    * vNIC MAC: a random unused MAC address (it should not change on reboots)

A sample ``/usbkey/config`` entry:

    .. code-block:: bash

        overlay_rule_adminoverlay="-e vxlan -p vxlan/listen_ip=0.0.0.0 -p vxlan/listen_port=4793 -s files -p files/config=/opt/custom/networking/adminoverlay_overlay.json -p mtu=1300"
        adminoverlay_0_vxlan_id="2"
        adminoverlay_0_vlan_id="2"
        adminoverlay_0_ip="10.44.44.13"
        adminoverlay_0_netmask="255.255.255.0"
        adminoverlay_0_mac="00:e5:dc:d5:d4:cf"

.. seealso:: Detailed instructions on how to create the `adminoverlay` overlay rule can be found in the :ref:`overlays automation guide<enable_overlays>`.

.. _overlays_adminoverlay_requirements:

Requirements for overlays
=========================
If you use one or more remote compute nodes, you must have the following on ALL compute nodes regardless of their location:
    * All compute nodes need to have **external** :ref:`NIC tag<network_nictag>` configured.
    * All compute nodes need to have a public IPv4 address on the external interface that is reachable from the internet.
    * All compute nodes need to have a default route set on external interface.
    * Each remote location must have a different name of :ref:`physical datacenter <cn_install_datacenter>`.

The reason for mandatory public IP addresses is because compute nodes are interconnected to a mesh network, sending overlay packets directly to the compute node that hosts the destination virtual machine (according to a virtual ARP routing table in ``files/config`` file).

.. warning:: Setting :ref:`physical datacenter <cn_install_datacenter>` name correctly during compute node installation is very important for overlay routing to work correctly. If your compute nodes can reach each other using the **admin** network, they need to have the same :ref:`physical datacenter <cn_install_datacenter>` name (so they don't need to use `IPSec` and they will communicate using the **admin** network). If the compute nodes cannot reach each other using the **admin** network, they **must** have a different :ref:`physical datacenter <cn_install_datacenter>` name.

In other words:
    * *If* sender's :ref:`PDC <cn_install_datacenter>` name == receiver's :ref:`PDC <cn_install_datacenter>` name **->** no IPSec and send overlay packets via **admin** network.
    * *If* sender's :ref:`PDC <cn_install_datacenter>` name != receiver's :ref:`PDC <cn_install_datacenter>` name **->** apply IPSec and send overlay packets via the **external** interface, directly to an external IP of the destination compute node.

Recommendations for overlays
============================
- It is recommended to create a separate overlay rule for user traffic (so the virtual ARP table is not shared with `adminoverlay`).
- If possible, configure your network switches to allow larger MTU (if not using remote compute nodes).
- Configure firewall on external interface of each compute node.

Configuring a firewall on each compute node
===========================================
As each compute node has a public IP address, it is recommended to protect this interface from potential attackers. Additionally, to prevent any IPSec misconfiguration or packet forgery - you may want to drop all overlay/VXLAN packets on the **external0** interface that are not protected by IPSec.

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

IPSec pre-shared keys generated by :ref:`esdc-overlay<esdc_overlay_cmd>` are unique for each pair of compute nodes. Therefore even discovering the IPSec key does not compromise the whole system, only the communication of two physical servers.

However, all compute nodes have their SSH RSA keys exchanged, so any compute node can connect to any other compute node using SSH without password (it is needed for backups, VM migrations and other administrative tasks). Therefore you should not install your remote compute nodes in unsafe locations as they could be possibly used as an attack vector. Use firewalls and also physical security, monitor SSH logins and compute node reboots. The integrated monitoring system is your good friend here.
