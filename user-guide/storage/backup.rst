.. _storage_backup:

Backup Storage Pool
*******************

Backups can be stored on any storage pool on a compute node that has backup functionality turned on.

Requirements
============

The backup storage pool has to have the following ZFS datasets:

* ``<pool>/backups/ds`` - Location used for dataset backups.
* ``<pool>/backups/file`` - Location used for file backups. It can also be a directory or a NFS/SMB mountpoint.

**ZFS dataset creation:**

.. code-block:: bash

    [root@node01 ~] zfs create -o compression=lz4 <pool>/backups/ds
    [root@node01 ~] zfs create -o compression=lz4 <pool>/backups/file

