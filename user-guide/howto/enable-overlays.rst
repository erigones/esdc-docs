.. _enable_overlays:

Enable Overlay Networking in Danube Cloud
*****************************************

Overlay networks are not enabled by default after Danube Cloud installation. You have to perform steps described in this page to make them work.

.. seealso:: Before proceeding, it is recommended to read XXX overview of Danube Cloud overlays and XXX overview of ``esdc-overlay`` command.

If you want to change overlays configuration later (e.g. add/modify/delete overlays, modify firewall configuration, etc), all you need to use is XXXref ``esdc-overlay`` command to make appropriate changes.

**After adding one or more new compute nodes, you have to run** XXXref esdc-overlay update **to enable overlays also on these new nodes.**

.. note:: Command ``esdc-overlay`` must be run from the first compute node (the one that was installed the first). Running it from any other node is also possible but before that you have to add that compute node's `ssh` key into ``root_authorized_keys`` metadata of `mgmt01.local` virtual machine in XXXref `admin` virtual datacenter.

If you don't know whether to enable also remote compute nodes support, read more about remote compute nodes XXX here.

.. _enable_overlays_no_rcn:

Steps to Enable Overlays Without Remote Compute Nodes
=====================================================
Without remote compute nodes the things are fairly simple. Just run:

    .. code-block:: bash

        [root@cn01 (myDC) ~]# esdc-overlay create mynewoverlay

For more options of ``esdc-overlay create`` command see XXX here.


.. _enable_overlays_reconfigure_hn:

Steps to Enable Overlays With Remote Compute Nodes Support
==========================================================
To support remote compute nodes, these additional steps are needed:
    - Add external public IP addresses to all compute nodes
    - Make the internal Danube Cloud services accessible from the internet
    - Create XXXref-overlays.rst `admin overlay`
    - Create additional overlay rules
    - Modify monitoring agent config

.. _enable_overlays_install_hn:

0. Add Public IP Addresses to Compute Nodes
-------------------------------------------
A public IP address is mandatory on all compute nodes. For more info see XXX here.

If you are about to install Danube Cloud from scratch, you can setup required options during install questions so you don't need to manually edit ``/usbkey/config``. If you already have your Danube Cloud installed, skip XXref here.
- XXXref na veci do installu
* Select `Advanced install`
* Configure external NIC tag with IP address facing to the internet
* Configure default gateway to external interface's gw


.. _enable_overlays_manual_reconf_hn:
On already installed Danube Cloud, you have to check the following setup on `all` compute nodes:
* Configure external IP address
  You need to have these options in ``/usbkey/config``:

    .. code-block:: bash

        external_nic=           # MAC addr of external network card
        external0_vlan_id=      # may be empty
        external0_ip=           # public IP address
        external0_netmask=

    Example:

    .. code-block:: bash

        external_nic=00:0c:29:d1:b9:dd
        external0_ip=80.1.65.141
        external0_netmask=255.255.255.192

* Set default route to external interface 
  You need to have this option in ``/usbkey/config``:

    .. code-block:: bash

        headnode_default_gateway=   # default GW of the public interface
        admin_gateway=              # GW of the admin network (optional)

    Example:

    .. code-block:: bash

        headnode_default_gateway=80.1.65.129
        admin_gateway=10.0.66.1


.. _enable_overlays_make_svc_accessible:

1. Make The Services Accessible From Internet
---------------------------------------------

XXXlink to _overlays_stretching_dc_over_inet

You have two options here:
    * Install access zone or any custom router virtual machine to forward traffic to management services (recommended)
    * Add public IP addresse to `mgmt01.local` service virtual machine so remote compute nodes can connect directly

.. _enable_overlays_install_access_zone:

Install access zone
===================
You can follow XXX this howto on how to install an access zone. You can skip `openvpn` part as it is not needed here. The most important part is setting up `ipfilter` XXX rules and XXX NAT configuration.

.. _enable_overlays_add_mgmt_pub_ip:

Add public IP address to `mgmt01.local`
=======================================

    * Log into the Danube Cloud XXX web GUI (from your inner network of by using ssh port forward e.g. ``ssh -L 4443:<IP_of_mgmt01>:443 root@CN1``)
    * Switch to XXX **admin** virtual datacenter
    * Go to **Datacenter -> Networks**
    * Click **Add Network** and create an external public network (over external XXX NIC tag), add some unused IP addresses (at least one)
    * Attach the new network to **admin** virtual datacenter
    * Go to **Servers -> mgmt01 -> Add NIC** and add the newly created external network
    * Set this new NIC as default network interface (uncheck **Primary NIC** on `net0` and check it on `net1` (`Advanced settings`))
    * Reboot mgmt01 VM with applying the config changes
    * Wait for GUI to become reachable again

Now you have the services accessible from the internet.
Optionally, it is recommended to restrict the allowed sources only to known IP addresses/subnets. You can do it directly in the `mgmt01.local` VM:

    .. code-block:: bash

        [user@my_laptop ~]# ssh root@cn1            # ssh to the first compute node
        [root@cn01 (myDC) ~]# source /usbkey/config
        [root@cn01 (myDC) ~]# ssh $mgmt_admin_ip    # ssh to the mgmt01
        [root@mgmt01 ~]# systemctl status iptables


.. _enable_overlays_create_adminoverlay:

2. Create admin overlay
-----------------------

Now we have to create admin overlay network called **adminoverlay** that serves the same purpose as a normal `admin` network but `adminoverlay` can spread geographically over the whole internet. For more info see XXX _overlays_adminoverlay here.

Log in to the first compute node and issue **esdc-overlay adminoverlay-init**. For more options on this command see XXX _esdc_overlay_create_adminoverlay.

    .. code-block:: bash

        [user@my_laptop ~]# ssh root@cn1            # ssh to the first compute node
        [root@cn01 (myDC) ~]# adminoverlay-init <adminoverlay_subnet/netmask>

This command will create `adminoverlay` on all compute nodes. You can verify it by running ``ipadm show-addr``.

Now go to GUI, create the appropriate `adminoverlay` network and add IP addresses to management virtual machines:
    * Switch to XXX **admin** virtual datacenter
    * Go to **Nodes -> your CN1 -> click Refresh button** to reload network configuration (do this on all compute nodes that are already installed)
    * Go to **Datacenter -> Networks -> Add Network** and create network `adminoverlay` (or any name), VLAN ID = 2, NIC tag = adminoverlay, VXLAN tag = 2, fill in network and netmask, no need for gateway
    * Add some usable IP addresses into this subnet
    * Attach `adminoverlay` network to **admin** virtual datacenter
    * On each compute node click **Edit -> Show advanced settings -> IP address**, change IP to the new overlay IP, click **Update**
    * Now go to **Servers** and add additional NICs from the `adminoverlay` network to these service VMs: mgmt01, mon01, img01 (as an additional NIC, not primary)
    * Remember or write down the assigned IP addresses for mgmt01 and mon01 as you will need them later
    * Apply the changes and reboot all edited VMs
    * Wait for GUI to become reachable again
    * Switch to **main** datacenter
    * Go to **Datacenter -> Settings -> Show global settings** and search for **VMS_IMAGE_VM_NIC** and set it to "2". It tells the system that compute nodes should contact the internal image server (``img01.local``) on the second NIC (the overlay one). Click **Update Settings** on the bottom (or hit enter when typing "2").

Now you have working overlay configuration. You can add your own overlays and XXX overlay rules.


.. _enable_overlays_create_orules:

3. Create additional overlay rules
----------------------------------
To create new overlay rules, see XXX esdc-overlay create command options.

The simplest command to create new overlay rule is

    .. code-block:: bash

        [root@cn01 (myDC) ~]# esdc-overlay create mynewoverlay

After this command, you need to refresh the compute node information in the GUI: **Nodes -> (all affected compute nodes) -> Refresh**.


.. _enable_overlays_zabbix_agent:

4. Modify monitoring agent config
---------------------------------
The last step is reconfigure monitoring to work over `adminoverlay`. We want to do two things:
    - Add new `adminoverlay` IP of `mon01.local` to configuration database, so new compute nodes will use this IP
    - Reconfigure existing compute nodes and change zabbix agent configuration.

Ssh into the first compute node and run:

    .. code-block:: bash

            MON_IP="${overlay IP of the mon01 VM}"          # example: MON_IP="1.2.3.4"
            query_cfgdb set /esdc/settings/zabbix/host "${MON_IP}"
            query_cfgdb creater /esdc/settings/remote/zabbix/host "${MON_IP}"
            sed -i '' -e 's/^Server=.*$/Server=${MON_IP}/' -e 's/^ServerActive=.*$/ServerActive=${MON_IP}/' /opt/zabbix/etc/zabbix_agentd.conf
            svcadm restart zabbix/agent

Then for each installed compute node run remote command:

    .. code-block:: bash

            ssh <compute_node_ip> sed -i '' -e 's/^Server=.*$/Server=${MON_IP}/' -e 's/^ServerActive=.*$/ServerActive=${MON_IP}/' /opt/zabbix/etc/zabbix_agentd.conf
            ssh <compute_node_ip> svcadm restart zabbix/agent


Now you should be all set for the Danube Cloud overlays.


.. _enable_overlays_add_cn:

Add a new local or remote compute node
======================================
A local compute node is not required to have a public IP address. But without it, such node cannot connect to remote compute nodes using overlays and cannot migrate virtual machines to/from remote nodes. Local overlays will work properly.

A remote node must use overlays.

There are several guidelines to follow during the installation of a compute node when using overlays:
    - select **Advanced Install**
    - configure external interface with IP address
    - configure default gateway to external interface's gw
    - when asked for Configuration database IP address
      - if it is a local node: fill in the local admin IP address of ``cfgdb01.local``
      - if it is a remote node: fill in the public IP address of ``mgmt01.local`` or the IP of installed ``access zone``

After joining the new compute node to the management, log into to first compute node and issue the following command to update all overlays on all compute nodes, including the new one:

    .. code-block:: bash

        esdc-overlay update

Last steps:
* Go to GUI
* Go to **Nodes -> (new compute node) -> click Refresh button** to reload network configuration
* Go to **Nodes -> (new compute node) -> Edit -> Show advanced settings -> IP address**, change IP to the new overlay IP, click **Update**

Now the new compute is ready for use.


