.. _esdc_overlays_cmd:

Overlays administration
=======================
To simplify deployment of overlay networking as much as possible, there is a command ``esdc-overlay`` that will do for you all operations described in this page. Moreover, it permanently stores the data in Danube Cloud's configuration database (CFGDB XXXlink to admin-dc.rst) so the compute node configuration can be easily re-applied at any time.

To apply all configuration to all/selected compute nodes, ``esdc-overlay`` runs `ansible` playbook that does all the hard work.

.. note:: Command ``esdc-overlay`` should be run in the shell on the first compute node (the one that hosts the ``mgmt01`` virtual machine).

.. seealso:: You need to enable overlays prior to administering them. See XXX How to enable overlays in Danube Cloud.

What ``esdc-overlay`` can do:
    * Create/modify overlay rules
    * Create/modify firewall configuration
    * List configured overlay rules
    * Create `adminoverlay`, create appropriate vNICs, assign `adminoverlay` IP/MAC addresses
    * Create and apply IPSec configuration
    * Restart appropriate system services if needed
    * Check overlay requirements

Creating an overlay rule
------------------------
Usage of ``create`` subcommand:
    .. code-block:: bash

        esdc-overlay create <overlay_rule_name> [node_list|all] [raw_overlay_rule_string]

Creating an overlay rule on all compute nodes in the Danube Cloud installation can be as simple as running
    .. code-block:: bash

        esdc-overlay create mynewoverlay

More complex usage can define subset of compute nodes that will host the new overlay rule:
    .. code-block:: bash

        esdc-overlay create localoverlay cn01.local,cn02.local,cn03.local

Or you can create completely custom overlay rule (all nodes, port 4790, MTU 1300):
    .. code-block:: bash

        esdc-overlay create customers all "-e vxlan -p vxlan/listen_ip=0.0.0.0,vxlan/listen_port=4790 -s files -p files/config=/opt/custom/networking/customers_overlay.json -p mtu=1300"

Notes:
    * If you provide a node list to ``esdc-overlay`` (anything other than `all`), only these compute nodes will be touched by ansible.
    * In the node list, you can provide also non-existent node names. This way you can configure future nodes in advance.

Updating an overlay rule
------------------------
Usage of ``create`` subcommand:
    .. code-block:: bash

        esdc-overlay update [overlay_rule_name] [node_list|all] [raw_overlay_rule_string]

``update`` has the same parameters as ``create``. It can alter any overlay rule parameters and the change is immediately pushed to all selected compute nodes.

``update`` subcommand can also be run without any parameters. In this mode it will (re)apply the configuration for all overlay rules on all compute nodes. It is very useful either to verify that the configuration is correct or to configure overlays on newly added compute nodes.

.. note:: After adding a new compute node, just run ``esdc-overlay update`` command. It will fully configure overlay networking on the new node(s).

Modify list of nodes that the specified overlay should be configured on (nodes cn*.local from 01 to 15):
    .. code-block:: bash

        esdc-overlay update localoverlay "$(seq -w 1 15 | xargs -I % echo cn%.local | tr '\n' ',')"

Re-apply configuration for `myrule` overlay rule (ansible will touch only nodes that the `myrule` should be on - it will retrieve the correct node list from CFGDB):
    .. code-block:: bash

        esdc-overlay update myrule

Delete an overlay rule
----------------------
Usage of ``delete`` subcommand:
    .. code-block:: bash

        esdc-overlay delete <overlay_rule_name>

Overlay rule will be first deleted on all compute nodes and then (if successful) from CFGDB.

List all configured overlay rules
---------------------------------
Usage of ``list`` subcommand:
    .. code-block:: bash

        esdc-overlay list

Sample output:
    .. code-block:: bash

        root@cn01:/root# esdc-overlay list
        NAME         PORT      NODELIST
        adminoverlay 4791      all
        customer1    4792      cn02.dc,cn03.dc,cn06.dc
        customer12   4793      cust01.local,cust02.local
        svc          4790      all

.. _esdc_overlay_create_adminoverlay:
Create adminoverlay
-------------------
Usage of ``adminoverlay-init`` subcommand + example:
    .. code-block:: bash

        esdc-overlay adminoverlay-init <adminoverlay_subnet/netmask> [nodename1=ip1,nodename=ip2,...]
        esdc-overlay adminoverlay-init 10.10.10.0/255.255.255.0 cn01.local=10.10.10.11,cn02.local=10.10.10.12

This subcommand will
    * Verify specified IP addresses
    * Create `adminoverlay` overlay rule
    * Generate/assign IP addresses for vNICs on all compute nodes
    * Generate static MAC addresses for vNICs
    * Write the configuration into ``/usbkey/config`` on all compute nodes
    * Reload ``network/virtual`` system service to apply new overlay config

Parameters:
    * `adminoverlay_subnet/netmask` - a network subnet with netmask that will be used for `adminoverlay` vNICs. It is actually an overlay equivalent of `admin` network (but the admin network is still needed)
    * `nodename1=ip1,...` - if you want to set specific IP addresses for some/all nodes, you can do it here. Unspecified nodes will have the IP address assigned automatically. All IP addresses must be from the `adminoverlay_subnet`.

Modify adminoverlay
-------------------
Usage of ``adminoverlay-update`` subcommand:
    .. code-block:: bash

        esdc-overlay adminoverlay-update [nodename1=ip1,nodename=ip2,...]

This subcommand can modify assigned IP addresses. It will (as all commands except `*list`) immediately run ansible to apply the configuration.

List adminoverlay info
----------------------
Usage of ``adminoverlay-list`` subcommand:
    .. code-block:: bash

        esdc-overlay adminoverlay-list

Sample output:
    .. code-block:: bash

        root@cn01:/root# esdc-overlay adminoverlay-list
        Adminoverlay subnet:  10.10.10.0
        Adminoverlay netmask: 255.255.255.0
        Adminoverlay vxlan_id: 2
        Adminoverlay vlan_id: 2
        
        IP           MAC                  NODE
        10.10.10.11  00:e5:dc:dc:26:c3    cn01.local
        10.10.10.12  00:e5:dc:0f:c0:25    cn02.local
        10.10.10.13  00:e5:dc:0f:c0:42    cn03.local

Enable firewall on all compute nodes
------------------------------------
Usage of ``globally-enable-firewall`` subcommand + example:
    .. code-block:: bash

        esdc-overlay globally-enable-firewall [allowed_IP_list]
        esdc-overlay globally-enable-firewall admin_IP1,allowed_IP2,good_subnet/24
        esdc-overlay globally-enable-firewall 12.13.14.0/26,100.150.200.128/25,1.2.3.4

By default, running ``esdc-overlay`` with ``create`` or ``update`` subcommand will create firewall rules that prevent sending unencrypted overlay packets over `external0` interface.

The ``globally-enable-firewall`` subcommand will switch the `ipfilter` on `external0` interfaces of all compute nodes to whitelist mode. That means that it will permit connections only from allowed destinations. Note that network interfaces other that `external0` will NOT be affected by this change. Virtual machines are also not affected by this operation. This is solely supposed to protect the hypervisors from internet threats.

Allowed destinations are:
    * all compute nodes
    * sources specified in `allowed_IP_list`

This subcommand can be used to update the `allowed_IP_list` after the firewall has been enabled.

The subcommand requires confirmation before applying changes on compute nodes. Running the subcommand without parameters can be used to review the actual firewall configuration.

Disable firewall on all compute nodes
-------------------------------------
Usage of ``globally-disable-firewall`` subcommand + example:
    .. code-block:: bash

        esdc-overlay globally-disable-firewall

This subcommand will revert the effect of ``globally-enable-firewall`` on all compute nodes. All nodes are switched to blacklist ipfilter mode (allow all except explicitly forbidden).

The `ipfilter` itself is still active and you can add your own custom rules manually to any compute node by creating/editing a file in ``/opt/custom/etc/ipf.d/`` directory and running ``/opt/custom/etc/rc-pre-network.d/010-ipf-restore.sh refresh``.

