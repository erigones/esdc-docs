.. _network_nictag:

NIC Tags
********

NIC tags serve for mapping :ref:`virtual networks <network_virtual>` to physical network interfaces. *Danube Cloud* comes with the **admin** NIC tag preconfigured, which is used for the **admin** network.

For other use cases, it is possible to add following NIC tags:

- external
- internal
- storage

After manually configuring NIC tags directly on the compute node, the :ref:`compute node's system information must be refreshed<node_actions>` in the *Danube Cloud* web management.
The new NIC tags will be present in the *NIC tag* dropdown menu when creating new :ref:`network<networks>`.

.. warning:: Overlay and etherstub NIC tags are created manually and it is the administrator's job to make sure that different nodes don't have NIC tags with the same name but different type. Removing one of the NIC tags with different type or setting the same type on NIC tag on all nodes will solve this issue.

.. note:: **external**, **internal**, **storage** NIC tags are preconfigured in the *Danube Cloud* install script. However, it is up to the data center administrator to do the proper configuration on all compute nodes.

.. note:: After installing *Danube Cloud*, it is recommended to configure the **external** NIC tag. (Even if it points to the same physical network interface/link aggregation as the **admin** NIC tag. If new network interfaces are added to the compute node in the future, it will be easier to just modify the NIC tag mapping and not the configuration of every virtual network).


Managing NIC Tags
=================

The ``nictagadm`` command is used for working with NIC tags on the compute node. It is possible to add, create or modify NIC tags with it.

There are 4 types of NIC tags available:

- normal
- aggregation
- etherstub
- overlay

.. warning:: Normal, aggregation, and etherstub NIC tags should only be managed using ``nictagadm``; if you use ``dladm`` to create and/or delete these NIC tags, unexpected behavior might occur.

.. note:: Overlay NIC tags are special because they are created based on the ``overlay_rules.json`` file. Once the first VM that uses overlay is created, overlay spawns into life.

.. seealso:: Overlays NIC tags are related to VXLAN configuration in :ref:`virtual networks <networks>`.

Adding normal/aggr NIC Tag
--------------------------

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

Adding etherstub NIC tag
------------------------

Etherstubs are created with the command shown below. Please make sure that etherstub name ends with a number, otherwise you will end up with an error.
Etherstubs created this way will be written to ``/usbkey/config``, and this makes them persistent over reboots.

.. code-block:: bash

        [root@node01 ~] nictagadm add -l stub0
        [root@node01 ~] nictagadm list
        NAME           MACADDRESS         LINK           TYPE
        stub0          -                  -              etherstub

Adding overlay NIC tag
----------------------

As opposed to other NIC tag types, overlays are not created using ``nictagadm`` command. They are created by adding ``/var/run/smartdc/networking/overlay_rules.json`` and ``/opt/custom/networking/my_overlay.json`` files.

``overlay_rules.json`` provides information to the operating system about properties of the overlays. Here is an example of how this file might look like:

.. code-block:: bash

        [root@node01 ~] cat /var/run/smartdc/networking/overlay_rules.json
        {
        "my_overlay": "-e vxlan -p vxlan/listen_ip=192.168.100.100,vxlan/listen_port=4790 -s files -p files/config=/opt/custom/networking/my_overlay.json -p mtu=1400",
        "another_overlay": "-e vxlan -p vxlan/listen_ip=192.168.200.200,vxlan/listen_port=4791 -s files -p files/config=/opt/custom/networking/another_overlay.json -p mtu=1400",
        "other_overlay": "-e vxlan -p vxlan/listen_ip=0.0.0.0,vxlan/listen_port=4790 -s files -p files/config=/opt/custom/networking/other_overlay.json -p mtu=1400"
        }

Deleting a NIC Tag
------------------

The ``nictagadm delete`` command should be used to delete NIC tags.

.. code-block:: bash

    [root@node01 ~] nictagadm delete external
    [root@node01 ~] nictagadm list
    NAME           MACADDRESS         LINK           TYPE
    admin          78:24:af:9c:3b:53  rge0           normal

Overlays must be deleted using both ``dladm`` command and removed manually from ``/var/run/smartdc/networking/overlay_rules.json``.

.. code-block:: bash

    [root@node01 ~] dladm show-overlay
    LINK               PROPERTY           PERM REQ VALUE      DEFAULT   POSSIBLE
    my_overlay2233    mtu                rw   -   1400       1400      576-8900
    my_overlay2233    vnetid             rw   -   2234       --        --
    my_overlay2233    encap              r-   -   vxlan      --        vxlan
    my_overlay2233    varpd/id           r-   -   1          --        --
    my_overlay2233    vxlan/listen_ip    rw   y   0.0.0.0    --        --
    my_overlay2233    vxlan/listen_port  rw   y   4700       4700      1-65535
    my_overlay2233    search             r-   -   files      --        direct,
                                                                        files,svp
    my_overlay2233    files/config       rw   y   /opt/custom/networking/my_overlay.json -- --

    [root@node01 ~] dladm delete-overlay my_overlay2234
    [root@node01 ~] nictagadm list
    NAME           MACADDRESS         LINK           TYPE
    admin          78:24:af:9c:3b:53  rge0           normal
