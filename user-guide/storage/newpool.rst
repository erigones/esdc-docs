.. _storage_newpool:

New Storage Pool Creation
*************************

After creating a new storage pool, following commands must be executed:

.. code-block:: bash

    [root@node01 ~] zfs set atime=off <pool>
    [root@node01 ~] zfs create -o mountpoint=none -o compression=gzip <pool>/cores

