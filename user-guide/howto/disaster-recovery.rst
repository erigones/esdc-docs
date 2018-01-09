.. _disaster_recovery:

Disaster Recovery
*****************

In order to have multiple disaster recovery options we suggest to schedule regular backups as well as regular snapshots. A typical backup/snapshot scheme would include doing backups at least once a day for a week or longer and doing snapshots once a hour for a day or two. The actual backup/snapshot strategy depends on each virtual server, services, use cases, associated contracts, etc.

.. note:: Virtual servers and containers may have more than one virtual disk. Backups and snapshots are scheduled for each virtual disk separately.

.. contents:: Table of Contents


----

.. _snapshot_recovery:

Recovery from Snapshot
######################

Snapshots are visible for each virtual server via the :ref:`GUI<snapshot>` and :ref:`API<api>` [01]_, which also includes the IDs of each snapshot.


Restore of Server Disk
~~~~~~~~~~~~~~~~~~~~~~

.. _snapshot_restore:

Rollback to the Same Server
---------------------------

This is a quick operation that can be performed from the :ref:`virtual server's snapshot view<snapshot>` or via the :ref:`API<api>` [02]_. The virtual server has to be stopped before the rollback.

.. warning:: Due to the nature of ZFS, all snapshots that are newer than the restored snapshot will be removed after a snapshot rollback.


.. _snapshot_restore_another_vm:

Restore to Another Server
-------------------------

This feature was introduced in *Danube Cloud* 3.0 and is currently available only via the :ref:`API<api>` [03]_. It uses the backup restore functionality under the hood. It is a slow operation because all snapshot data must be transfered to another virtual server's disk. The source virtual server may be running or stopped.
The target virtual server must:

    - be deployed and stopped;
    - be in the same virtual data center as the source virtual server;
    - have the same OS type as the source virtual server;
    - have the same disk size as the source snapshot's disk.

.. warning:: All snapshots of the virtual server's target disk will be deleted after the restore operation.


.. _snapshot_restore_files:

Restore of Individual Files
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The procedure of restoring individual files from a snapshot depends on the OS type of the virtual server:

    * *KVM* - The only option is to :ref:`restore the snapshot to another temporary virtual server<snapshot_restore_another_vm>`, then boot the temporary server by using a rescue CD and look for the files from the rescue environment. The temporary server should have a virtual NIC attached so it is possible to copy the restored files to another server.

    * *SunOS/Linux Zone* - Thanks to ZFS, it is possible to browse the files in a snapshot. Starting from *Danube Cloud* version 3.0, the snapshots are accessible from inside the running server:

        - Snapshots of first (root) virtual disk are mounted in the ``/checkpoints`` directory.
        - Snapshots of the second (data) virtual disk are mounted in the ``/<dataset-mountpoint>/.zfs/snapshot`` directory (the dataset mountpoint is by default in ``/zones/<vm-uuid>/data``).

        The snapshots are mounted in their own directories named after the snapshot ID. The snapshot ID for each snapshot can be obtained through the :ref:`API<api>` [01]_.

        The snapshot files can be also accessed on the compute node even if the virtual server is stopped. The snapshot directories are available in ``/<zpool>/<vm-uuid>/.zfs/snapshot`` for the first (root) virtual disk and in ``/<zpool>/<vm-uuid>/data/.zfs/snapshot`` for the second (data) virtual disk.


Snapshot API
~~~~~~~~~~~~

.. [01] List VM snapshots including snapshot IDs
    ``es get /vm/<hostname_or_uuid>/snapshot -full [-dc <dc_name>] [-disk_id 1]``

.. [02] Rollback VM snapshot
    ``es set /vm/<hostname_or_uuid>/snapshot/<snapname> [-dc <dc_name>] [-disk_id 1] [-force]``

.. [03] Restore VM snapshot to another VM
    ``es set /vm/<hostname_or_uuid>/snapshot/<snapname> [-dc <dc_name>] [-disk_id 1] [-force] -target_hostname_or_uuid <another_vm> -target_disk_id <another_vm_disk_id>``

.. seealso:: Please see the :ref:`full API reference documentation <api>` for more information.


----

.. _backup_recovery:

Recovery from Backup
####################

Backups are visible for each virtual server via the :ref:`GUI<backup>` and :ref:`API<api>` [11]_, which also includes the IDs of each backup. Backups can be also accessed from a backup node's :ref:`GUI view<node_backup>` and :ref:`API function<api>` [12]_. The backup node's view also includes backups for non-existent virtual servers.


.. _backup_restore:

Restore of Server Disk
~~~~~~~~~~~~~~~~~~~~~~

The backup restore operation can be performed from the :ref:`virtual server's backup view<backup>`, the :ref:`compute node's backup view<node_backup>` or through the :ref:`API<api>` [13]_. This task can be very slow because all backup data must be transfered from the backup node to the target virtual server's disk. The backup can be restored to the same or another virtual server. The target virtual server must:

    - be deployed and stopped;
    - be in the same virtual data center as the source virtual server;
    - have the same OS type as the source virtual server;
    - have the same disk size as the source backup's disk.

.. warning:: All snapshots of the virtual server's target disk will be deleted after the restore operation.


.. _backup_restore_files:

Restore of Individual Files
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The procedure of restoring individual files from a backups depends on the OS type of the virtual server:

    * *KVM* - The only option is to :ref:`restore the backup to another temporary virtual server<backup_restore>`, then boot the temporary server by using a rescue CD and look for the files from the rescue environment. The temporary server should have a virtual NIC attached so it is possible to copy the restored files to another server.

    * *SunOS/Linux Zone* - The same procedure as for restoring *KVM* backups can be also applied for *SunOS/Linux Zones*. Additionally, ZFS dataset backups are based on snapshots, which can be also accessed from the backup node. The snapshot files of containers can be browsed on the backup node in ``/<zpool>/backups/ds/<vm-uuid>-disk<disk_id>/.zfs/snapshot``. The backup snapshots are mounted in their own directories named after the backup ID, which can be obtained through the :ref:`API<api>` [11]_ [12]_.

Backup API
~~~~~~~~~~

.. [11] List VM backups including backup IDs for one virtual server
    ``es get /vm/<hostname_or_uuid>/backup -full [-dc <dc_name>] [-disk_id 1]``

.. [12] List VM backups including backup IDs on a backup node
    ``es get /node/<hostname_or_uuid>/backup -full``

.. [13] Restore VM backup, optionally to another VM
    ``es set /vm/<hostname_or_uuid>/backup/<bkpname> [-dc <dc_name>] [-disk_id 1] [-force] [-target_hostname_or_uuid <another_vm>] [-target_disk_id <another_vm_disk_id>]``
.. seealso:: Please see the :ref:`full API reference documentation <api>` for more information.


----

.. _manual_recovery:

Recovery without Danube Cloud API or GUI
########################################

It is possible to restore snapshots and backups even after losing the :ref:`Danube Cloud mgmt01 virtual server<admin_dc>`. The :ref:`mgmt01 virtual server<admin_dc>` should be **restored first** and all other virtual servers should be restored through the *Danube Cloud* GUI or API as described in the :ref:`sections above<backup_recovery>`.

.. note:: Virtual servers do not directly depend on the :ref:`Danube Cloud internal virtual servers<admin_dc>` and will continue to function even without the :ref:`Danube Cloud internal servers<admin_dc>`.

.. warning:: The :ref:`Danube Cloud internal virtual servers<admin_dc>` cannot be reinstalled or redeployed to an existing *Danube Cloud* infrastructure. Please make sure that you perform regular backups of all :ref:`Danube Cloud internal servers<admin_dc>`.


Manual Recovery from Backup
~~~~~~~~~~~~~~~~~~~~~~~~~~~


.. _manual_backup_locate:

Manually Locating Backups
-------------------------

First, we need to find the backup we want to restore. All ZFS dataset backups have metadata stored on the backup node in ``/zones/backups/manifests/ds/<vm-uuid>-disk<disk_id>``. The actual ZFS dataset backups are stored as snapshots under ``zones/backups/ds/<vm-uuid>-disk<disk_id>``. All commands should be run on the backup node as root.

.. code-block:: bash

    [user@laptop ~] ssh root@backup-node01
    [root@backup-node01 ~] ls -l /zones/backups/manifests/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0

        -rw-r--r--   1 root     root        4347 Jan  2 01:30 is-67432.json
        -rw-r--r--   1 root     root        4347 Jan  3 01:30 is-67504.json
        -rw-r--r--   1 root     root        4347 Jan  4 01:30 is-67574.json
        -rw-r--r--   1 root     root        4347 Jan  5 01:30 is-67645.json
        -rw-r--r--   1 root     root        4347 Jan  6 01:30 is-67721.json
        -rw-r--r--   1 root     root        4347 Jan  7 01:30 is-67792.json
        -rw-r--r--   1 root     root        4347 Jan  8 01:30 is-67863.json

    [root@backup-node01 ~] json < /zones/backups/manifests/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0/is-67721.json hostname

        mgmt01.local

    [root@backup-node01 ~] zfs list -t snapshot -r zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0  # List snapshots on a dataset

        NAME                                                                   USED  AVAIL  REFER  MOUNTPOINT
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67432   547M      -  8.83G  -
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67504   325M      -  8.83G  -
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67574   325M      -  8.80G  -
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67645   369M      -  8.85G  -
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721   307M      -  8.81G  -
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67792   353M      -  8.83G  -
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67863      0      -  8.81G  

    [root@backup-node01 ~] zfs get all zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  # Get all information about the snapshot

        NAME                                                                  PROPERTY              VALUE                  SOURCE
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  type                  snapshot               -
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  creation              Sat Jan  6  1:30 2018  -
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  used                  307M                   -
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  referenced            8.81G                  -
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  compressratio         1.93x                  -
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  devices               on                     default
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  exec                  on                     default
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  setuid                on                     default
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  xattr                 on                     default
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  nbmand                off                    default
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  primarycache          all                    default
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  secondarycache        all                    default
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  defer_destroy         off                    -
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  userrefs              0                      -
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  mlslabel              none                   default
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  refcompressratio      1.93x                  -
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  written               525M                   -
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  clones                                       -
        zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721  logicalreferenced     14.6G                  -


You can use the following script to get a list of all ZFS dataset backups along with the VM hostname and backup creation time:

.. code-block:: bash

    [user@laptop ~] ssh root@backup-node01
    [root@backup-node01 ~] cd /zones/backups/manifests/ds
    [root@backup-node01 /zones/backups/manifests/ds] find . -type f -name '*.json' | while read mdata;
            do
                echo -e "$(json < ${mdata} hostname)\t${mdata}\t$(stat -c '%y' ${mdata})";
            done

        mgmt01.local  ./f7860689-c435-4964-9f7d-2d2d70cfe389-disk0/is-67432.json    2018-01-02 01:30:04.290493690 +0100
        mgmt01.local  ./f7860689-c435-4964-9f7d-2d2d70cfe389-disk0/is-67863.json    2018-01-08 01:30:05.300791005 +0100
        mgmt01.local  ./f7860689-c435-4964-9f7d-2d2d70cfe389-disk0/is-67792.json    2018-01-07 01:30:04.744398647 +0100
        mgmt01.local  ./f7860689-c435-4964-9f7d-2d2d70cfe389-disk0/is-67504.json    2018-01-03 01:30:03.196072816 +0100
        mgmt01.local  ./f7860689-c435-4964-9f7d-2d2d70cfe389-disk0/is-67645.json    2018-01-05 01:30:03.204474172 +0100
        mgmt01.local  ./f7860689-c435-4964-9f7d-2d2d70cfe389-disk0/is-67721.json    2018-01-06 01:30:03.391434182 +0100
        mgmt01.local  ./f7860689-c435-4964-9f7d-2d2d70cfe389-disk0/is-67574.json    2018-01-04 01:30:03.079370089 +0100
        mon01.local   ./a28faa4d-d0ee-4593-938a-f0d062022b02-disk0/is-67480.json    2018-01-02 18:30:03.866274704 +0100
        mon01.local   ./a28faa4d-d0ee-4593-938a-f0d062022b02-disk0/is-67622.json    2018-01-04 18:30:03.945609759 +0100
        mon01.local   ./a28faa4d-d0ee-4593-938a-f0d062022b02-disk0/is-67698.json    2018-01-05 18:30:04.025041240 +0100
        mon01.local   ./a28faa4d-d0ee-4593-938a-f0d062022b02-disk0/is-67770.json    2018-01-06 18:30:05.062745267 +0100
        mon01.local   ./a28faa4d-d0ee-4593-938a-f0d062022b02-disk0/is-67914.json    2018-01-08 18:30:02.908963686 +0100
        mon01.local   ./a28faa4d-d0ee-4593-938a-f0d062022b02-disk0/is-67841.json    2018-01-07 18:30:02.987273858 +0100
        mon01.local   ./a28faa4d-d0ee-4593-938a-f0d062022b02-disk0/is-67550.json    2018-01-03 18:30:03.851469970 +0100


.. _manual_backup_restore:

Manually Restoring Backups
--------------------------

1. Copy the VM manifest to a target compute node:

    .. code-block:: bash

        [user@laptop ~] ssh root@backup-node01
        [root@backup-node01 ~] scp /zones/backups/manifests/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0/is-67721.json root@node02:/opt/new-vm.json

2. Modify the VM manifest:

    - The *KVM* manifest must not contain: ``disks.*.image_size``, ``disks.*.image_uuid``, ``disks.*.zfs_filesystem``, ``disks.*.path``.
    - The *SunOS/Linux Zone* manifest must contain the ``image_uuid`` property and the image should be imported via ``imgadm``.

    .. code-block:: bash

        [user@laptop ~] ssh root@node02
        [root@node02 ~] cat /opt/new-vm.json | json > /opt/new-vm.nice.json
        [root@node02 ~] vim /opt/new-vm.nice.json

3. Create new VM and make sure that it is stopped:

    .. code-block:: bash

        [user@laptop ~] ssh root@node02
        [root@node02 ~] vmadm create -f /opt/new-vm.nice.json
        [root@node02 ~] vmadm stop -F <new-vm-uuid> 

4. Get the target disk of the new VM (the disk, to which we want to restore the backup):

    - *KVM* virtual server:

        .. code-block:: bash

            [root@node02 ~] vmadm get <new-vm-uuid> | json disks.0.zfs_filesystem  # First disk
            [root@node02 ~] vmadm get <new-vm-uuid> | json disks.1.zfs_filesystem  # Second disk

    - *SunOS/Linux Zone* virtual server:

        .. code-block:: bash

            [root@node02 ~] vmadm get <new-vm-uuid> | json zfs_filesystem   # First disk
            [root@node02 ~] vmadm get <new-vm-uuid> | json json datasets.0  # Second disk

5. Restore backup by sending the ZFS data directly from the backup node to the target disk of our new VM (obtained in the previous step):

    .. code-block:: bash

        [user@laptop ~] ssh root@backup-node01
        [root@backup-node01 ~] zfs send zones/backups/ds/f7860689-c435-4964-9f7d-2d2d70cfe389-disk0@is-67721 | ssh root@node02 zfs receive -F zones/<new-vm-uuid>-disk0

        [user@laptop ~] ssh root@node02
        [root@node02 ~] vmadm start <new-vm-uuid>  # Start new VM

    .. note:: The ``zfs receive`` command will completely overwrite the target disk with the data from the source ZFS snapshot.

