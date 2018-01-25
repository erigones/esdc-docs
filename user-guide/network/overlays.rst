.. _network_nictag:

Overlay networking
******************

Network overlays in SmartOS and Danube Cloud are concept of encapsulating network traffic from virtual machines using the VXLAN technology. In SmartOS, overlays are a way of extending usable number of separate :ref:`virtual networks <network_virtual>` (e.g. one overlay per customer).

Danube Cloud extends this concept by adding IPSec VPN mesh to secure the (by default unencrypted) VXLAN packets which allows to securely strech the :ref:`virtual networks <network_virtual>` over the internet without the need of dedicated interconnects between multiple datacenters. Direct advantage of this approach is a possibility of creating remote compute nodes that are managed by the same Danube Cloud management regardless of their location on the internet.

In other words, Danube Cloud can create geographically spread transparent L2 networks which can be used by virtual machines to communicate as if they were connected into a local switch.

.. seealso:: This page explains concepts of overlay networking. Setting up all overlay parts in Danube Cloud manually is possible but quite time consuming. That's why we have created an ``esdc-overlay`` command that automates creating and managing of overlay rules, admin overlays and firewalling. See :ref:`overlays automation <howto/overlays-automation>`.

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
- overlay rules are a template how to create overlays
- overlays are using UDP VXLAN packets to encapsulate traffic
- overlays/VXLANs require configured and working underlying physical network links (plain IP connectivity)
- overlays in Danube Cloud work over **admin** network (**admin** or **admin0** NIC) or over the internet (**external0** NIC)
- there can be multiple overlay rules (each on a different UDP port number)

How are overlays created?
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
There are several factors that make the final overlay-encapsulated packet larger:
    * VXLAN header - encapsulates packet from virtual network into an UDP packet
    * VLAN header - additional VLAN header inside of the VXLAN packet
    * IPSec header - adds ESP header with encryption info

For these reasons the MTU of overlay vNICs is by default lowered from 1500 to 1400 bytes. If you are able to change the MTU on all the underlying physical switch infrastructure, we recommend increasing the MTU to 1800 bytes. Then you can set MTU at overlay rule definition to 1500.

However this is not the case if you have a remote compute node internet infrastructure most probably doesn't allow higher MTUs. In this case you need to keep the MTU at 1400 or sometimes even lower (see Troubleshooting IPSec in Danube Cloud).

Adminoverlay as a virtual admin network
=======================================


Requirements for overlays
=========================
If you use one or more remote compute nodes, you must have following on ALL compute nodes regardless the location:
    * ALL compute nodes need to have ``external`` NIC tag configured
    * ALL compute nodes need to have a public IPv4 address on the external interface that is reachable from the internet
    * ALL compute nodes need to have a default route set on external interface
    * Each remote location must have a different name of :ref:`physical datacenter <cn_install_datacenter>`

The reason for mandatory public IP addresses is because compute nodes are interconnected to a mesh network, sending overlay pakets directly to the compute node that hosts the destination virtual machine (according to a virtual ARP routing table in ``files/config``).

.. warning:: Setting :ref:`physical datacenter <cn_install_datacenter>` name correctly during compute node installation is very important for overlay routing to work correctly. If your compute nodes can reach each other using the `admin` network, they need to have the same :ref:`physical datacenter <cn_install_datacenter>` name (so they don't need to use `IPSec` and they will communicate using the `admin` network). If the compute nodes cannot reach each other using the admin network, they *must* have a different :ref:`physical datacenter <cn_install_datacenter>` name.

In other words:
    * Sender's :ref:`PDC <cn_install_datacenter>` name == receiver's :ref:`PDC <cn_install_datacenter>` name: no IPSec and send overlay packets via `admin` network
    * Sender's :ref:`PDC <cn_install_datacenter>` name != receiver's :ref:`PDC <cn_install_datacenter>` name: apply IPSec and send overlay packets to the `external` IP of the destination compute node

Recommendations for overlays
============================
- it is recommended to create a separate overlay rule for user traffic (and not use the adminoverlay)
- if possible, configure your network switches to allow larger packets (MTU)
- configure firewall on external interface of each compute node
- if you need throughput 

CO dalej:
- networks stack overview - kde sa overlays nachadzaju, ze su UDP
- about MTU
- firewalling
- security - cert fingerprint
- nevyhody
  - priepustnost IPSec
  - higher complexity (vxlan layer, IPSec, virtual routing tables)
  - MTU

