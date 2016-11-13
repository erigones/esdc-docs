.. _storage_redundancy:

Storage Pool Redundancy
***********************

ZFS supports following basic RAID vdev types:

* Stripe (RAID0)
* Mirror (RAID1)
* RAIDZ  (Single Parity RAIDZ)
* RAIDZ2 (Double Parity RAIDZ)
* RAIDZ3 (Triple Parity RAIDZ)

.. note:: By combining multiple vdev types in the storage pool, ZFS will automatically do stripping between them.

ZFS supports following nested RAID vdev types:

* Stripped Mirror (RAID10)
* Stripped RAIDZ  (Stripped RAIDZ)
* Stripped RAIDZ2 (Stripped RAIDZ2)
* Stripped RAIDZ3 (Stripped RAIDZ3)

Basic RAID vdev Types
=====================

Stripe (RAID 0)
---------------

Stripped vdev is equivalent to RAID 0. It does not provide any level of redundancy and it should be used only with a different type of redundancy (e.g. stripped mirror or stripped RAIDZ1/2/3).

========================== ==============
 Capacity                    N x S(min)
-------------------------- --------------
 Minimal number of drives    2
-------------------------- --------------
 Fault tolerance             none
-------------------------- --------------
 Read performance            Nx
-------------------------- --------------
 Write performance           Nx
========================== ==============

    (**N** - number of disks, **S** - size of the disk, **min** - smallest disk's size)

How to create a storage pool with stripped vdevs
`````````````````````````````````````````````````

.. code-block:: bash

    [root@node01 ~] zpool create storage disk0 disk1

How to add another stripped vdev into a storage pool
````````````````````````````````````````````````````

.. code-block:: bash

    [root@node01 ~] zpool add storage disk2

.. warning:: Using striping alone is not recommended for production use!


Mirror (RAID 1)
---------------

Mirrored vdev is equivalent to RAID 1. ZFS supports the creation of N-way mirrored vdevs. Mirroring provides a good level of redundancy.

========================== ==============
 Capacity                   1/N x S(min)
-------------------------- --------------
 Minimal number of drives    2
-------------------------- --------------
 Fault tolerance             N - 1
-------------------------- --------------
 Read performance            Nx
-------------------------- --------------
 Write performance           1x
========================== ==============

    (**N** - number of disks, **S** - size of the disk, **min** - smallest disk's size)

How to create a storage pool with mirror vdev
`````````````````````````````````````````````

.. code-block:: bash

    [root@node01 ~] zpool create storage mirror disk0 disk1

.. note:: ZFS allows creating mirror vdevs by attaching a new disk to the existing one. This will create a 2-way mirror from a single disk, a 3-way mirror from a 2-way mirror, etc. Only the redundancy level will be increased by attaching a new disk, not the available size within the storage pool.

.. warning:: When a storage pool has one disk and creating a mirror is required, use ``zpool attach``. Using ``zpool add`` will create a **stripe** between the new disk and the existing in the storage pool. **Reverting this action is not possible without copying data off the storage pool!**

How to create a mirror in single drive storage pool or increase mirror redundancy
`````````````````````````````````````````````````````````````````````````````````

.. code-block:: bash

    [root@node01 ~] zpool attach storage disk0 disk1

.. note:: It is possible to remove a disk from a mirror vdev by detaching it. The operation is refused if there are no other valid replicas of the data.

How to remove disk from existing mirror in a storage pool
`````````````````````````````````````````````````````````

.. code-block:: bash

    [root@node01 ~] zpool detach storage disk0


RAIDZ (Single Parity RAIDZ)
---------------------------

RAIDZ, also called RAIDZ1, is a data/parity distribution scheme similar to RAID 5. It protects against RAID 5 *write hole* and is also faster as is does not have to perform the *read-modify-write* sequence.

========================== ==============
 Capacity                   (N - 1) * S(min)
-------------------------- --------------
 Minimal number of drives    3
-------------------------- --------------
 Fault tolerance             1
-------------------------- --------------
 Read performance            Nx
-------------------------- --------------
 Write performance           1x
========================== ==============

(**N** - number of disks, **S** - size of the disk, **min** - smallest disk's size)

How to create a storage pool with a RAIDZ vdev
``````````````````````````````````````````````

.. code-block:: bash

    [root@node01 ~] zpool create storage raidz disk0 disk1 disk2

.. warning:: It is not possible to extend a RAIDZ vdev with additional disks. The storage pool can be extended with a new RAIDZ vdev.

How to extend a storage pool with a RAIDZ vdev
``````````````````````````````````````````````

.. code-block:: bash

    [root@node01 ~] zpool add storage raidz disk3 disk4 disk5


RAIDZ2 (Double Parity RAIDZ)
----------------------------

RAIDZ2 is similar to RAID 6. The parity is stored twice.

========================== ==============
 Capacity                    (N - 2) * S(min)
-------------------------- --------------
 Minimal number of drives    4
-------------------------- --------------
 Fault tolerance             2
-------------------------- --------------
 Read performance            Nx
-------------------------- --------------
 Write performance           1x
========================== ==============

(**N** - number of disks, **S** - size of the disk, **min** - smallest disk's size)

How to create a storage pool with a RAIDZ2 vdev
```````````````````````````````````````````````

.. code-block:: bash

    [root@node01 ~] zpool create storage raidz2 disk0 disk1 disk2 disk3

.. warning:: It is not possible to extend a RAIDZ2 vdev with additional disks. The storage pool can be extended with a new RAIDZ2 vdev.

How to extend a storage pool with a RAIDZ2 vdev
```````````````````````````````````````````````

.. code-block:: bash

    [root@node01 ~] zpool add storage raidz disk4 disk5 disk6 disk7


RAIDZ3 (Triple Parity RAIDZ)
----------------------------

RAIDZ3 uses triple parity and guarantees an excellent level of redundancy. Generally, it should be used with large sized disks.

========================== ==============
 Capacity                    (N - 3) * S(min)
-------------------------- --------------
 Minimal number of drives    5
-------------------------- --------------
 Fault tolerance             3
-------------------------- --------------
 Read performance            Nx
-------------------------- --------------
 Write performance           1x
========================== ==============

(**N** - number of disks, **S** - size of the disk, **min** - smallest disk's size)

How to create a storage pool with a RAIDZ3 vdev
```````````````````````````````````````````````

.. code-block:: bash

    [root@node01 ~] zpool create storage raidz3 disk0 disk1 disk2 disk3 disk4

.. warning:: It is not possible to extend a RAIDZ3 vdev with additional disks. The storage pool can be extended with a new RAIDZ3 vdev.

How to extend a storage pool with a RAIDZ3 vdev
```````````````````````````````````````````````

.. code-block:: bash

    [root@node01 ~] zpool add storage raidz disk4 disk5 disk6 disk7 disk8


Nested RAID vdev Types
======================

Stripped mirror (RAID 10)
-------------------------

Stripped mirror is a combination a stripping between mirror vdev types. This is a best performing RAID level for small random reads.

========================== ==============
 Capacity                    G * (1/N * S(min))
-------------------------- --------------
 Minimal number of drives    4
-------------------------- --------------
 Fault tolerance             G x (N - 1)
-------------------------- --------------
 Read performance            G * Nx
-------------------------- --------------
 Write performance           N/Gx
========================== ==============

(**N** - number of disks in one mirror vdev, **S** - size of the disk, **min** - smallest disk's size, **G** - number of mirror vdevs in the storage pools)

How to create a storage pool with a stripped mirror vdev
````````````````````````````````````````````````````````

.. code-block:: bash

    [root@node01 ~] zpool create storage mirror disk0 disk1 mirror disk2 disk3

How to extend a storage pool with a mirror vdev and create a stripped mirror vdev
`````````````````````````````````````````````````````````````````````````````````

.. code-block:: bash

    [root@node01 ~] zpool add storage mirror disk4 disk5


Stripped RAIDZ (RAIDZ+0)
------------------------

Stripped RAIDZ vdev is stripping across RAIDZ vdev types.

========================== ==============
 Capacity                    G * ((N - 1) * S(min))
-------------------------- --------------
 Minimal number of drives    4
-------------------------- --------------
 Fault tolerance             G
-------------------------- --------------
 Read performance            G * Nx
-------------------------- --------------
 Write performance           G * 1x
========================== ==============

(**N** - number of disks in one RAIDZ vdev, **S** - size of the disk, **min** - smallest disk's size, **G** - number of RAIDZ vdevs in the storage pools)

How to create a storage pool with a stripped RAIDZ vdev
```````````````````````````````````````````````````````

.. code-block:: bash

    [root@node01 ~] zpool create storage \
                    raidz disk0 disk1 disk2 disk3 disk4 \
                    raidz disk5 disk6 disk7 disk8 disk9

How to extend a storage pool with a RAIDZ vdev to create a stripped RAIDZ vdev
``````````````````````````````````````````````````````````````````````````````

.. code-block:: bash

    [root@node01 ~] zpool add storage \
                    raidz disk10 disk11 disk12 disk13 disk14


Stripped RAIDZ2 (RAIDZ2+0)
--------------------------

Stripped RAIDZ2 vdev is stripping across RAID22 vdev types. It is a good trade-off between available capacity and redundancy.

========================== ==============
 Capacity                    G * ((N - 2) * S(min))
-------------------------- --------------
 Minimal number of drives    6
-------------------------- --------------
 Fault tolerance             2 * G
-------------------------- --------------
 Read performance            G * Nx
-------------------------- --------------
 Write performance           G * 1x
========================== ==============

(**N** - number of disks in one RAIDZ2 vdev, **S** - size of the disk, **min** - smallest disk's size, **G** - number of RAIDZ2 vdevs in the storage pools)

How to create a storage pool with a stripped RAIDZ2 vdev
````````````````````````````````````````````````````````

.. code-block:: bash

    [root@node01 ~] zpool create storage \
                    raidz2 disk0 disk1 disk2 disk3 disk4 \
                    raidz2 disk5 disk6 disk7 disk8 disk9

How to extend a storage pool with a RAIDZ2 vdev to create a stripped RAIDZ2 vdev
````````````````````````````````````````````````````````````````````````````````

.. code-block:: bash

    [root@node01 ~] zpool add storage \
                    raidz2 disk10 disk11 disk12 disk13 disk14


Stripped RAIDZ3 (RAID Z3+0)
---------------------------

Stripped RAIDZ3 vdev is stripping across RAIDZ3 vdev types.

========================== ==============
 Capacity                    G * ((N - 3) * S(min))
-------------------------- --------------
 Minimal number of drives    8
-------------------------- --------------
 Fault tolerance             3 * G
-------------------------- --------------
 Read performance            G * Nx
-------------------------- --------------
 Write performance           G * 1x
========================== ==============

(**N** - number of disks in one RAIDZ3 vdev, **S** - size of the disk, **min** - smallest disk's size, **G** - number of RAIDZ3 vdevs in the storage pools)

How to create a storage pool with stripped RAIDZ3 vdevs
```````````````````````````````````````````````````````

.. code-block:: bash

    [root@node01 ~] zpool create storage \
                    raidz3 disk0 disk1 disk2 disk3 disk4 disk5 disk6 disk7 \
                    raidz3 disk8 disk9 disk10 disk11 disk12 disk13 disk14 disk15

How to extend a storage pool with a RAIDZ3 vdev to create stripped RAIDZ3 vdevs
```````````````````````````````````````````````````````````````````````````````

.. code-block:: bash

    [root@node01 ~] zpool add storage \
                    raidz3 disk16 disk17 disk18 disk19 disk20 disk21 disk22 disk23 disk24 disk25


Hot spares (Spare)
==================

ZFS allows devices to be associated with pools as *"hot spares"*. These devices are not actively used in the pool, but when an active device fails, it is automatically replaced by a hot spare. Hot spares can be shared across multiple storage pools.

How to create a storage pool with a hot spare
---------------------------------------------

.. code-block:: bash

    [root@node01 ~] zpool create storage mirror disk0 disk1 spare disk2

How to create a storage pool and extend it with a hot spare
-----------------------------------------------------------

.. code-block:: bash

    [root@node01 ~] zpool create storage mirror disk0 disk1
    [root@node01 ~] zpool add storage spare disk2

How to replace a disk manually in a storage pool
------------------------------------------------

.. code-block:: bash

    [root@node01 ~] zpool replace storage disk0

.. note:: Disk replacement can be done automatically by the system upon inserting a new disk drive. This behavior is controlled by the ``autoreplace`` property of the storage pool and is disabled by default. If you want to enable it, execute ``zpool set autoreplace=on <pool>``.

How to remove a disk from a storage pool
----------------------------------------

.. code-block:: bash

    [root@node01 ~] zpool replace storage disk0 disk2
    [root@node01 ~] zpool remove storage disk0

.. note:: Manual disk replacement should be done when disk starts to show S.M.A.R.T errors or for simple replacement for a different model.

.. note:: It is required to :ref:`refresh the compute node's system information <node_actions>` after a new storage pool is created. The storage pool will be then available in the *Danube Cloud* web management.

