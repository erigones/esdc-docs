.. _enable_overlays:

Enable Overlay Networking in Danube Cloud
*****************************************

Overlay networks are not enabled by default after *Danube Cloud* installation. You have to perform steps described in this page to make them work.

.. seealso:: Before proceeding, it is recommended to read the overview of *Danube Cloud* :ref:`overlay networking<overlays>` and overview of the :ref:`esdc-overlay<esdc_overlay_cmd>` command.

If you want to change overlays configuration later (e.g. add/modify/delete overlays, modify firewall configuration, etc.), all you need to use is the :ref:`esdc-overlay<esdc_overlay_cmd>` command, which will perform the appropriate changes on all/selected compute nodes.

**After adding one or more new compute nodes, you have to run :ref:`esdc-overlay update<esdc_overlay_cmd_update>` to enable overlays also on these new nodes.**

.. note:: The ``esdc-overlay`` command must be run from the first compute node (the one that was installed first). Running it from any other node is also possible but before that you have to add that compute node's SSH key into the ``root_authorized_keys`` metadata of the `mgmt01.local` virtual server in the :ref:`admin virtual data center<admin_dc>`.

If you don't know whether to enable also remote compute nodes support, read more about remote compute nodes :ref:`here<overlays_stretching_dc_over_inet>`.

.. _enable_overlays_no_rcn:

Steps to Enable Overlays Without Remote Compute Nodes
=====================================================
Without remote compute nodes the things are fairly simple. Just run:

    .. code-block:: bash

        [root@node01 (myDC) ~] esdc-overlay create mynewoverlay

For more options of the ``esdc-overlay create`` subcommand have a look :ref:`here<esdc_overlay_cmd_create>`.


.. _enable_overlays_reconfigure_hn:

Steps to Enable Overlays With Remote Compute Nodes Support
==========================================================
To support remote compute nodes, these additional steps are needed:
    - Add external public IP addresses to all compute nodes.
    - Make the internal *Danube Cloud* *admin services* accessible from the internet.
    - Create the :ref:`adminoverlay<overlays_adminoverlay>`.
    - Create additional overlay rules.
    - Modify monitoring agent configuration.

.. _enable_overlays_install_hn:

0. Add Public IP Addresses to Compute Nodes
-------------------------------------------
A public IP address is mandatory on all compute nodes. For more info see :ref:`here<overlays_adminoverlay_requirements>`.

If you are about to install *Danube Cloud* from scratch, you can setup required options during install questions so you don't need to manually edit ``/usbkey/config``. If you have already deployed *Danube Cloud*, skip :ref:`here<enable_overlays_manual_reconf_hn>`.

During the compute node installation:

    * Select :ref:`Advanced installation<cn_install_advanced>`.
    * Configure external NIC tag with IP address facing to the internet.
    * Set default gateway to external interface's gateway.

.. _enable_overlays_manual_reconf_hn:

On already installed *Danube Cloud*, you have to check the following setup on **all** compute nodes:

* Configure external IP address.
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

* Set default route to external interface.
    You need to have this option in ``/usbkey/config``:

        .. code-block:: bash

            headnode_default_gateway=   # default GW of the public interface
            admin_gateway=              # GW of the admin network (optional)

    Example:

        .. code-block:: bash

            headnode_default_gateway=80.1.65.129
            admin_gateway=10.0.66.1


.. _enable_overlays_make_svc_accessible:

1. Make Admin Services Accessible From Internet
-----------------------------------------------

.. seealso:: More information about extending *Danube Cloud* to other physical datacenters can be found in a :ref:`separate chapter<overlays_stretching_dc_over_inet>`.

You have two options here:
    * :ref:`(A)<enable_overlays_install_access_zone>` Install access zone or any custom router virtual machine to forward traffic to *Danube Cloud* *admin services* (recommended).
    * :ref:`(B)<enable_overlays_add_mgmt_pub_ip>` Add public IP addresses to the :ref:`mgmt01.local<admin_dc>` service virtual server so remote compute nodes can connect directly.

.. _enable_overlays_install_access_zone:

Install access zone
~~~~~~~~~~~~~~~~~~~
You can follow this :ref:`guide<access_zone>` on how to install an access zone. You can skip the OpenVPN part as it is not needed here. The most important part is setting up :ref:`firewall rules<access_zone_ipfilter>` and :ref:`NAT configuration<create_more_nat_rules>`.

.. _enable_overlays_add_mgmt_pub_ip:

Add public IP address to `mgmt01.local`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    * Log into the *Danube Cloud* management portal (from your local network by using SSH port forward e.g. ``ssh -L 4443:<IP_of_mgmt01>:443 root@node01``).
    * :ref:`Switch<switch_dc>` to the **admin** virtual data center.
    * Go to :guilabel:`Datacenter -> Networks`.
    * Click :guilabel:`Add Network` and create an external public :ref:`network<networks>` (over external :ref:`NIC tag<network_nictag>`); add some unused :ref:`IP addresses<network_ips>` (at least one).
    * Attach the new network to **admin** virtual data center.
    * Go to :guilabel:`Servers -> mgmt01 -> Add NIC` and add a :ref:`virtual NIC<vm_nics>` with the newly created external network.
    * Set this new virtual NIC as default network interface (uncheck *Primary NIC* on the first VM NIC and check it on newly added VM NIC in :guilabel:`Advanced settings`)).
    * :ref:`Reboot<vm_actions>` the `mgmt01.local` virtual server with applying the configuration changes.
    * Wait for the GUI to become reachable again.

Now you have the services accessible from the internet.
Optionally, it is recommended to restrict the allowed sources only to known IP addresses/subnets. You can do it directly in the `mgmt01.local` VM:

    .. code-block:: bash

        [user@laptop ~] ssh root@node01                  # ssh to the first compute node
        [root@node01 (myDC) ~] source /usbkey/config
        [root@node01 (myDC) ~] ssh $mgmt_admin_ip     # ssh to the mgmt01
        [root@mgmt01 ~] systemctl status iptables


.. _enable_overlays_create_adminoverlay:

2. Create Admin Overlay
-----------------------

Now, we have to create an admin overlay network called **adminoverlay** that serves the same purpose as a normal **admin** network but `adminoverlay` can spread geographically over the whole internet. For more info see :ref:`here<overlays_adminoverlay>`.

Log in to the first compute node and run ``esdc-overlay adminoverlay-init``. For more information and available options of this command see :ref:`here<esdc_overlay_create_adminoverlay>`.

    .. code-block:: bash

        [user@laptop ~] ssh root@node01            # ssh to the first compute node
        [root@node01 (myDC) ~] adminoverlay-init <adminoverlay_subnet/netmask>

This command will create `adminoverlay` on all compute nodes. You can verify it by running ``ipadm show-addr``.

Now go to the GUI, create the appropriate `adminoverlay` virtual network and add IP addresses to :ref:`admin virtual servers<admin_dc>`:
    * :ref:`Switch<switch_dc>` to the **admin** virtual data center.

    * Go to :guilabel:`Nodes -> <your CN>` and click on the :guilabel:`Refresh` button to reload network configuration (do this on all compute nodes that are already installed).
    * Go to :guilabel:`Datacenter -> Networks`, click on :guilabel:`Add Network` and create a new :ref:`network<networks>` `adminoverlay` (or any name), VLAN ID = **2**, NIC tag = **adminoverlay**, VXLAN tag = **2**, fill in network and netmask, no need for gateway.
    * Add some usable :ref:`IP addresses<network_ips>` into this new virtual network.
    * Attach the virtual network to the **admin** virtual data center.
    * On each compute node click on :guilabel:`Edit -> Show advanced settings` and change the **IP address** to the new overlay IP, click :guilabel:`Update`.
    * Now go to :guilabel:`Servers` and add additional virtual NICs that use the `adminoverlay` network to these admin virtual servers: `mgmt01`, `mon01`, `img01` (as an additional NIC, not primary).
    * Remember or write down the assigned IP addresses for `mgmt01` and `mon01` as you will need them later.
    * Apply the changes and :ref:`reboot<vms_actions>` all edited virtual servers.
    * Wait for GUI to become reachable again.
    * :ref:`Switch<switch_dc>` to the **main** virtual data center.
    * Go to :guilabel:`Datacenter -> Settings` and click on :guilabel:`Show global settings`. Search for the **VMS_IMAGE_VM_NIC** setting and set it to ``2``. It tells the *Danube Cloud* system that compute nodes should contact the internal image server (`img01.local`) on the second virtual NIC (the overlay one). Click :guilabel:`Update Settings` on the bottom (or hit enter when typing ``2``).

Now, you have a working overlay configuration. You can add your own overlays and :ref:`overlay rules<enable_overlays_create_orules>`.


.. _enable_overlays_create_orules:

3. Create Additional Overlay rules
----------------------------------
To create new overlay rules, see :ref:`esdc-overlay create<esdc_overlay_cmd_create>` command options.

The simplest command to create a new overlay rule is:

    .. code-block:: bash

        [root@node01 (myDC) ~] esdc-overlay create mynewoverlay

After this command, you need to refresh the compute node information in the GUI: :guilabel:`Nodes -> (all affected compute nodes) -> Refresh`.


.. _enable_overlays_zabbix_agent:

4. Modify Monitoring Agent Configuration
----------------------------------------
The last step is to reconfigure monitoring to work over `adminoverlay`. We want to do two things:
    - Add new `adminoverlay` IP of `mon01.local` to the configuration database, so that new compute nodes will use this IP.
    - Reconfigure existing compute nodes and change the Zabbix agent configuration.

Ssh into the first compute node and run:

    .. code-block:: bash

        [root@node01 (myDC) ~] MON_IP="${overlay IP of the mon01 VM}"          # example: MON_IP="1.2.3.4"
        [root@node01 (myDC) ~] query_cfgdb set /esdc/settings/zabbix/host "${MON_IP}"
        [root@node01 (myDC) ~] query_cfgdb creater /esdc/settings/remote/zabbix/host "${MON_IP}"
        [root@node01 (myDC) ~] sed -i '' -e 's/^Server=.*$/Server=${MON_IP}/' -e 's/^ServerActive=.*$/ServerActive=${MON_IP}/' /opt/zabbix/etc/zabbix_agentd.conf
        [root@node01 (myDC) ~] svcadm restart zabbix/agent

Then for each installed compute node run remote command:

    .. code-block:: bash

        [root@node01 (myDC) ~] ssh <compute_node_ip> sed -i '' -e 's/^Server=.*$/Server=${MON_IP}/' -e 's/^ServerActive=.*$/ServerActive=${MON_IP}/' /opt/zabbix/etc/zabbix_agentd.conf
        [root@node01 (myDC) ~] ssh <compute_node_ip> svcadm restart zabbix/agent


Now you should be all set for the *Danube Cloud* overlays.


.. _enable_overlays_add_cn:

Add a New Local or Remote Compute Compute Node
==============================================
A local compute node is not required to have a public IP address. But without it, such node cannot connect to remote compute nodes using overlays and cannot migrate virtual machines to/from remote nodes. Local overlays will work properly.

A remote node must use overlays.

There are several guidelines to follow during the installation of a compute node when using overlays:
    - Select :ref:`Advanced installation<cn_install_advanced>`.
    - Configure external interface with IP address.
    - Set default gateway to external interface's gateway.
    - When asked for :ref:`Configuration database IP address<cn_install_esdc>`:
      - if it is a local node: fill in the local admin IP address of `cfgdb01.local`,
      - if it is a remote node: fill in the public IP address of `mgmt01.local` or the IP of installed `access zone`.

After the new compute node is discovered by the *Danube Cloud* system, log into to first compute node and issue the following command to update all overlays on all compute nodes, including the new one:

    .. code-block:: bash

        esdc-overlay update

Final steps:
    * Go to GUI.
    * Go to :guilabel:`Nodes -> (new compute node)` and click on the :guilabel:`Refresh` button to pull the network configuration from the compute node.
    * Go to :guilabel:`Nodes -> (new compute node) -> Edit -> Show advanced settings` and change the **IP address** to the new overlay IP, click :guilabel:`Update`.

Now, the new compute is ready for use.
