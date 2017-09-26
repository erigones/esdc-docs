.. _network_nictag:

NIC Tags
********

NIC tags serve for mapping :ref:`virtual networks <network_virtual>` to physical network interfaces. *Danube Cloud* comes with the **admin** NIC tag preconfigured, which is used for the **admin** network.

For other use cases, it is possible to add following NIC tags:

- external
- internal
- storage

Administrator can also add new NIC tags with custom name or type (normal, overlay or etherstub). These new NIC tags are then collected from the node when Refresh button in node's Details view is pressed.
The new NIC tags will be present in the *NIC tag* dropdown menu when creating new network.

.. warning:: Overlay and etherstub NIC tags are created manually and it is the administrator's job to make sure that different nodes don't have NIC tags with the same name but different type. Removing one of the NIC tags with different type or setting the same type on NIC tag on all nodes will solve this issue.

.. note:: **external**, **internal**, **storage** NIC tags are preconfigured in the *Danube Cloud* install script. However, it is up to the data center administrator to do the proper configuration on the compute nodes.

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

.. note:: Overlay NIC tags are special because they are created based on ``overlay_rules.json``. Once the first VM that uses overlay is created, overlay spawns into life.

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
Etherstubs created this way will be written to ``/usbkey/config``, and this makes them persistent over the reboots.

.. code-block:: bash

        [root@node01 ~] nictagadm add -l stub0
        [root@node01 ~] nictagadm list
        NAME           MACADDRESS         LINK           TYPE
        stub0          -                  -              etherstub

Adding overlay NIC tag
----------------------

As opposed to other NIC tag types, overlays are not created using ``nictagadm`` command. They are created by adding ``/var/run/smartdc/networking/overlay_rules.json`` and ``/var/run/smartdc/networking/my_overlay1.json`` files.

``overlay_rules.json`` provides information to the operating system about properties of the overlays. Here is the example of how this file might look like:

.. code-block:: bash

        [root@node01 ~] cat /var/run/smartdc/networking/overlay_rules.json
        {
        "my_overlay1": "-e vxlan -p vxlan/listen_ip=192.168.100.100,vxlan/listen_port=4790 -s files -p files/config=/var/run/smartdc/networking/my_overlay1.json -p mtu=1400",
        "my_overlay2": "-e vxlan -p vxlan/listen_ip=192.168.200.200,vxlan/listen_port=4791 -s files -p files/config=/var/run/smartdc/networking/my_overlay2.json -p mtu=1400",
        "my_overlay3": "-e vxlan -p vxlan/listen_ip=0.0.0.0,vxlan/listen_port=4790 -s files -p files/config=/var/run/smartdc/networking/my_overlay3.json -p mtu=1400"
        }

Deleting a NIC Tag
------------------

The ``nictagadm delete`` command should be used to delete NIC tags.

.. code-block:: bash

    [root@node01 ~] nictagadm delete external
    [root@node01 ~] nictagadm list
    NAME           MACADDRESS         LINK           TYPE
    admin          78:24:af:9c:3b:53  rge0           normal

Overlays can be deleted by using both ``dladm`` or ``nictagadm``, though ``nictagadm`` is prefered due to the consistency.
To delete overlay, you need to use **name/vnetid** to identify overlay to be deleted, without vnetid the nictagadm will not be able to identify and delete overlay.

.. code-block:: bash

    [root@node01 ~] nictagadm delete my_overlay/2234
    [root@node01 ~] nictagadm list
    NAME           MACADDRESS         LINK           TYPE
    admin          78:24:af:9c:3b:53  rge0           normal
