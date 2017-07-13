.. _network_nictag:

NIC Tags
********

NIC tags serve for mapping :ref:`virtual networks <network_virtual>` to physical network interfaces. *Danube Cloud* comes with the **admin** NIC tag preconfigured, which is used for the **admin** network.

For other use cases, it is possible to add following NIC tags:

- external
- internal
- storage

.. note:: **external**, **internal**, **storage** NIC tags are preconfigured in the *Danube Cloud* system. However, it is up to the data center administrator to do the proper configuration on the compute nodes.

.. note:: After installing *Danube Cloud*, it is recommended to configure the **external** NIC tag. (Even if it points to the same physical network interface/link aggregation as the **admin** NIC tag. If new network interfaces are added to the compute node in the future, it will be easier to just modify the NIC tag mapping and not the configuration of every virtual network).


Managing NIC Tags
=================

The **nictagadm** command is used for working with NIC tags on the compute node. It is possible to add, create or modify NIC tags with it.

Adding a NIC Tag
----------------

.. code-block:: bash

    [root@node01 ~] nictagadm list
    NAME           MACADDRESS         LINK           TYPE
    admin          78:24:af:9c:3b:53  rge0           normal
    [root@node01 ~] nictagadm delete external
    [root@node01 ~] nictagadm add external 78:24:af:9c:3b:53
    [root@node01 ~] nictagadm list
    NAME           MACADDRESS         LINK           TYPE
    external       78:24:af:9c:3b:53  rge0           normal
    admin          78:24:af:9c:3b:53  rge0           normal

.. note:: For mapping a NIC tag to a link aggregation interface, it is necessary to use the physical link aggregation name (e.g. *aggr0*) instead of the MAC address.

    .. code-block:: bash

        [root@node01 ~] nictagadm add external aggr0
        [root@node01 ~] nictagadm list
        NAME           MACADDRESS         LINK
        external       -                  aggr0
        admin          -                  aggr0

Deleting a NIC Tag
------------------

.. code-block:: bash

    [root@node01 ~] nictagadm delete external
    [root@node01 ~] nictagadm list
    NAME           MACADDRESS         LINK           TYPE
    admin          78:24:af:9c:3b:53  rge0           normal

