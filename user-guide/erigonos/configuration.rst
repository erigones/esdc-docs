.. _cn_config:

Compute Node Configuration
**************************

The compute node runs a modified version of the `SmartOS <https://wiki.smartos.org>`__ operating system, which is also called *ErigonOS*. The base operating system without the *Danube Cloud* software is also called a Platform Image.

The compute node configuration is stored in the ``/usbkey/config`` file. The ``/usbkey`` folder is placed on the compute node's primary storage (*zones* pool) and contains a copy of the USB installation media. After changing the ``/usbkey/config`` file the compute node should be rebooted for changes to be applied correctly.

.. seealso:: For more information about the persistent compute node configuration see https://wiki.smartos.org/display/DOC/Persistent+Configuration+for+the+Global+Zone


/usbkey/config options
######################

.. note:: The ``/usbkey/config`` must be source-able by bash (i.e., it can be validated by running ``source /usbkey/config``).


Networking
----------

MAC address setup
~~~~~~~~~~~~~~~~~

- **change_mac** - Semicolon-separated list of MAC address pairs, which are delimited by a comma (e.g., ``aa:bb:cc:11:22:33,dd:ee:ff:44:55:66;f6:e5:d4:c3:b2:a1,1f:2e:3d:4c:5b:6a``). Each network interface that has the first MAC address in every pair will have its MAC address changed for the second MAC address in that pair during boot. This feature can be used to free the MAC address of a physical interface for use by a VNIC.

DNS configuration
~~~~~~~~~~~~~~~~~

- **dns_resolvers** - Comma-separated list of DNS resolvers that will be configured as nameservers in ``/etc/resolv.conf``.
- **dns_domain** - DNS search domain which will be set in ``/etc/resolv.conf``.
- **dns_options** - The value will be used as a parameter for the *options* keyword in ``/etc/resolv.conf``.

NTP configuration
~~~~~~~~~~~~~~~~~

- **ntp_hosts** - Comma-separated list of NTP servers set as time servers in ``ntp.conf``.

Link aggregation
~~~~~~~~~~~~~~~~

.. seealso:: Configuration of network interface aggregations is described in a :ref:`separate chapter<network_aggregation>`.

- **<aggr-name>_aggr** - Comma-separated list of one or more MAC addresses of physical network interfaces that should be combined into one 802.3ad link aggregation.
- **<aggr-name>_lacp_mode** - One of: ``off``, ``active``, ``passive``.
- **<aggr-name>_mtu** - MTU size of the link aggregation interface.

NIC tag and VNIC configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. seealso:: Configuration of NIC tags is described in a :ref:`separate chapter<network_nictag>`.

.. seealso:: Configuration of network interfaces is described in a :ref:`separate chapter<network_interface>`.

- **headnode_default_gateway** - IP address set as default gateway.

- **etherstub** - Comma-separated list of etherstub names that will be created during boot.

- **overlay_rule_<name>** - Overlay rule definition which will be set into ``/var/run/smartdc/networking/overlay_rules.json``.

- **<nic_tag>_nic** - Normal NIC tag definition.

- **<nic_tag>_<vnic-suffix_integer>_{ip,netmask,vlan_id,mac,mtu}** - VNIC definition.

    .. note:: The configuration parameters for the **admin** network do not contain the VNIC integer suffix.

    .. code-block:: bash
        :caption: VNIC over normal physical interfaces or aggregations.

        foobar_nic=11:22:33:aa:bb:cc
        # Or foobar_nic=aggr0 for VNIC/nic_tag over aggregation interface named `aggr0`
        foobar0_ip=192.168.11.22
        foobar0_netmask=255.255.255.0
        foobar0_vlan_id=...
        foobar0_mac=...
        foobar0_mtu=...

    .. code-block:: bash
        :caption: VNIC on etherstub. The etherstub name must be listed in the appropriate setting, e.g., ``etherstub=test30`` (see above).

        test30_0_ip=172.16.33.44
        test30_0_netmask=255.255.240.0
        test30_0_vlan_id=...
        test30_0_mac=...
        test30_0_mtu=...

    .. code-block:: bash
        :caption: VNIC on overlay. There must be an ``overlay_rule_ham_eggs=`` setting for the overlay rule (see above).

        ham_eggs_0_vxlan_id=1234
        ham_eggs_0_ip=10.55.66.77
        ham_eggs_0_netmask=255.255.0.0
        ham_eggs_0_vlan_id=...
        ham_eggs_0_mac=...
        ham_eggs_0_mtu=...

System configuration
--------------------

- **datacenter_name** - Physical data center name.
- **hostname** - Compute node hostname. The hostname **cannot** be changed after the compute node was already registered in *Danube Cloud*.

Virtual machines
----------------

- **vnc_listen_address** - IP address that will be used as the listen address of the VNC console of a KVM virtual machine.

Danube Cloud services
---------------------

The *Danube Cloud* service settings are automatically set by the installer and are used to deploy virtual servers in the :ref:`admin virtual data center<admin_dc>` on the first compute node. Other compute nodes use only the ``cfgdb_admin_ip`` and ``esdc_install_password`` to connect and extract information from the configuration database.

- **admin_email**
- **mgmt_admin_ip**
- **mon_admin_ip**
- **dns_admin_ip**
- **img_admin_ip**
- **cfgdb_admin_ip**
- **esdc_install_password**
