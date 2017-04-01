.. _network_aggregation:

Network Interface Aggregation
*****************************

ErigonOS allows NIC aggregation of multiple physical links via LACP in order to achieve link redundancy or increased network throughput.

.. note:: Network interface aggregation configuration is available only via CLI and it is recommended that the compute node is restarted and configuration is tested before putting any production workload onto the compute node.


NIC aggregation configuration on the headnode
#############################################

1. Find out the MAC address of network interfaces, which need to be aggregated:

    .. code-block:: bash

        [root@headnode (dc) ~] dladm show-phys -m
        LINK         SLOT     ADDRESS            INUSE CLIENT
        bnx0         primary  e4:1f:13:b3:ff:38  yes   bnx0
        bnx1         primary  e4:1f:13:b3:ff:39  yes   bnx1

2. Execute ``/usbkey/scripts/mount-usb.sh`` and mount the USB key, which holds the configuration file. The configuration file is located in ``/mnt/usbkey/config``.

3. Add a ``<aggregation_name>_aggr`` (e.g. ``aggr0_aggr``) line to the configuration file. This line must contain comma-separated MAC addresses of all physical links, which have to be aggregated.

    .. code-block:: bash

        # admin_nic is the nic admin_ip will be connected to for headnode zones.
        aggr0_aggr=e4:1f:13:b3:ff:38,e4:1f:13:b3:ff:39
        # The following line is optional - the LACP mode will default to "off".
        aggr0_lacp_mode=active

        # VM nics with admin or storage nic_tags will now have their vnics
        # created on the aggregation:
        admin_nic=aggr0
        storage_nic=aggr0

        # Configure IPs as you would for regular NICs.
        admin_ip=192.168.33.101
        storage_ip=172.17.0.101

    For configuring the LACP mode, it is possible to use the ``<aggregation_name>_lacp_mode`` directive (e.g. ``aggr0_lacp_mode``) and it can have one of the following values:

        - active
        - passive
        - off

4. Save the changes made to the configuration file and unmount the USB key: ``umount /mnt/usbkey``.
5. Reboot the system by running ``reboot``. When the system comes back online, the aggregation should be configured:

    .. code-block:: bash

        [root@headnode (dc) ~] sysinfo | json "Link Aggregations"
        {
            "aggr0": {
            "LACP mode": "active",
            "Interfaces": [
                "igb0",
                "igb1"
            ]
            }
        }

6. The aggregation status can be displayed by using the ``dladm`` command:

    .. code-block:: bash

        [root@dev01 (digitalis) ~]# dladm show-aggr -x
        LINK        PORT           SPEED DUPLEX   STATE     ADDRESS            PORTSTATE
        aggr0       --             1000Mb full    up        e4:1f:13:b3:ff:38  --
                    bnx0           1000Mb full    up        e4:1f:13:b3:ff:38  attached
                    bnx1           1000Mb full    up        e4:1f:13:b3:ff:39  attached


NIC aggregation configuration on the compute node
#################################################

1. Find out the MAC address of network interfaces, which need to be aggregated:

    .. code-block:: bash

        [root@cn01 (dc) ~] dladm show-phys -m
        LINK         SLOT     ADDRESS            INUSE CLIENT
        igb0         primary  e4:1f:13:b3:ff:38  yes  igb0
        igb1         primary  e4:1f:13:b3:ff:39  yes  igb1

2. Open the configuration file. The configuration file is located in ``/usbkey/config``.
3. Add ``<aggregation_name>_aggr`` (e.g. ``aggr0_aggr``) line to the configuration file. This line must contain comma-separated MAC addresses of all physical links, which have to be aggregated.

    .. code-block:: bash

        # admin_nic is the nic admin_ip will be connected to for headnode zones.
        aggr0_aggr=e4:1f:13:b3:ff:38,e4:1f:13:b3:ff:39
        # The following line is optional - the LACP mode will default to "off".
        aggr0_lacp_mode=active

        # VM nics with admin or storage nic_tags will now have their vnics
        # created on the aggregation:
        admin_nic=aggr0
        storage_nic=aggr0

        # Configure IPs as you would for regular NICs.
        admin_ip=192.168.33.101
        storage_ip=172.17.0.101

    For configuring the LACP mode, it is possible to use the ``<aggregation_name>_lacp_mode`` directive (e.g. ``aggr0_lacp_mode``) and it can have one of the following values:

        - active
        - passive
        - off

4. Save the changes made to the configuration file.
5. Reboot the system by running ``reboot``. When the system comes back online, the aggregation should be configured:

    .. code-block:: bash

        [root@cn01 (dc) ~] sysinfo | json "Link Aggregations"
        {
            "aggr0": {
            "LACP mode": "active",
            "Interfaces": [
                "igb0",
                "igb1"
            ]
            }
        }

6. The aggregation status can be displayed by using the ``dladm`` command:

    .. code-block:: bash

        [root@dev01 (digitalis) ~]# dladm show-aggr -x
        LINK        PORT           SPEED DUPLEX   STATE     ADDRESS            PORTSTATE
        aggr0       --             1000Mb full    up        e4:1f:13:b3:ff:38  --
                    bnx0           1000Mb full    up        e4:1f:13:b3:ff:38  attached
                    bnx1           1000Mb full    up        e4:1f:13:b3:ff:39  attached

