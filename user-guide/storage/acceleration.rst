Storage Pool Acceleration
*************************

ZFS supports advanced features to accelerate I/O performance of the storage:

* Increasing read I/O performance by using ARC.
* Increasing synchronous write I/O performance by using a dedicated solid-state drive (SSD).


ZFS ARC
=======

All available RAM is automatically used for intelligent data caching. It is called the *ARC (Adaptive Replacement Cache)*. During initial compute node configuration, ARC memory requirements should be taken into consideration, and some part of available memory should be dedicated to it. This can be configured via the :ref:`RAM coefficient node setting <compute_node_settings>`.

.. seealso:: For observing ARC activity and performance, please see the :ref:`storage pool troubleshooting <storage_diagnostic>` chapter.


Synchronous Write Acceleration by Using a Dedicated SSD (SLOG)
==============================================================

ZFS caches write data in RAM and sync them in N second intervals to the persistent storage. When synchronous writes are requested, ZFS intent log (ZIL) is activated, and it also writes data into RAM and also to the persistent storage. ZIL will use a small portion of data drives themselves to store log traffic. As every write has to be acknowledged by the much slower persistent storage, it might cause latency. This behavior can be modified by dedicating a faster drive (e.g. SSD or NVRAM) for the intent log (separate log (SLOG) or log vdev). Usage of a SLOG device increases security and overall write performance of the storage pool.

.. note:: The ZFS intent log is never read unless a power outage or another interruption occurs (before the data is written to the storage pool). It is read next time a storage pool is mounted, and data is recreated and written to the storage pool.

How to create a storage pool with a SLOG device
-----------------------------------------------

.. code-block:: bash

    [root@node01 ~] zpool create storage mirror disk0 disk1
    [root@node01 ~] zpool add storage log disk2

How to add a SLOG device to an existing storage pool
----------------------------------------------------

.. code-block:: bash

    [root@node01 ~] zpool add storage log disk2

.. note:: SLOG devices can also be put into a mirror. This will protect against failures, which are highly unlikely (e.g. power outage with SLOG drive failure).

How to create a storage pool with mirrored SLOG devices
-------------------------------------------------------

.. code-block:: bash

    [root@node01 ~] zpool create storage mirror disk0 disk1
    [root@node01 ~] zpool add storage log mirror disk2 disk3

How to add mirrored SLOG devices to an existing storage pool
------------------------------------------------------------

.. code-block:: bash

    [root@node01 ~] zpool add storage log mirror disk2 disk3

