.. _storage_diagnostic:

Storage Pool Troubleshooting
****************************

How to display storage pool status
##################################

.. code-block:: bash

    [root@headnode (mydc) ~] zpool status
      pool: zones
     state: ONLINE
      scan: none requested
    config:

        NAME        STATE     READ WRITE CKSUM
        zones       ONLINE       0     0     0
          raidz1-0  ONLINE       0     0     0
            c0t0d0  ONLINE       0     0     0
            c0t1d0  ONLINE       0     0     0
            c0t2d0  ONLINE       0     0     0
            c0t3d0  ONLINE       0     0     0

    errors: No known data errors

.. note:: The command ``zpool status -x`` shows only storage pools with problems.

How to display ``RAW`` capacity of a storage pool
#################################################

.. code-block:: bash

    [root@headnode (mydc) ~] zpool list
    NAME    SIZE  ALLOC   FREE   FRAG  EXPANDSZ    CAP  DEDUP  HEALTH  ALTROOT
    zones  2.17T  26.5G  2.15T     0%         -     1%  1.00x  ONLINE  -

* SIZE - Total size of the storage pool.
* ALLOC - The amount of used space within the pool.
* FREE - The amount of free space available in the pool.
* CAP - Percentage of pool space used.
* HEALTH - The current health of the storage pool.

How to display the amount of free space on a ZFS dataset/volume
###############################################################

.. code-block:: bash

    [root@headnode (mydc) ~] zfs list zones
    NAME    USED  AVAIL  REFER  MOUNTPOINT
    zones   132G  1.44T   643K  /zones

How to display the amount of used space on a ZFS dataset/volume
###############################################################

.. code-block:: bash

    [root@headnode (mydc) ~] zfs list -o space zones/...-disk0
    NAME             AVAIL   USED  USEDSNAP  USEDDS  USEDREFRESERV  USEDCHILD
    zones/...-disk0  1.46T  22.2G      162M   2.14G          19.9G          0


How to display compression effectiveness
########################################

.. code-block:: bash

    [root@headnode (mydc) ~] zfs get compressratio zones/...-disk0
    NAME             PROPERTY         VALUE  SOURCE
    zones/...-disk0  compressratio    3.64x     -


How to display I/O operations in the storage pool by device
###########################################################

.. code-block:: bash

    [root@headnode (mydc) ~] zpool iostat -v zones 5
                   capacity     operations    bandwidth
    pool        alloc   free   read  write   read  write
    ----------  -----  -----  -----  -----  -----  -----
    zones       26.5G  2.15T    174     69   714K   520K
      raidz1    26.5G  2.15T    174     69   714K   520K
        c0t0d0      -      -    100     29   209K   182K
        c0t1d0      -      -     99     28   177K   180K
        c0t2d0      -      -    100     29   203K   182K
        c0t3d0      -      -     97     28   169K   180K
    ----------  -----  -----  -----  -----  -----  -----

How to display device utilization
#################################

.. code-block:: bash

    [root@headnode (mydc) ~] iostat -xzn 1
                        extended device statistics
        r/s    w/s   kr/s   kw/s wait actv wsvc_t asvc_t  %w  %b device
       12.9    0.0   61.7    0.0  0.0  0.0    0.2    0.7   0   1 lofi1
       15.9   14.8   97.6   55.1  0.0  0.0    0.0    0.0   0   0 ramdisk1
        0.3    0.2    6.4    0.0  0.0  0.0    0.3    1.7   0   0 c1t0d0
       71.1   29.2  154.5  172.3  0.0  0.1    0.0    0.7   0   2 c0t0d0
       70.6   28.0  128.9  170.5  0.0  0.1    0.0    0.7   0   2 c0t1d0
       69.8   29.2  145.0  172.3  0.0  0.1    0.0    0.9   0   2 c0t2d0
       68.1   28.1  122.9  170.6  0.0  0.1    0.0    0.8   0   2 c0t3d0
      269.2  113.9  505.4  686.8  3.1  0.3    8.1    0.8   1   3 zones

* r/s - Number of ``read`` operations per second.
* w/s - Number of ``write`` operations per second.
* kr/s - The amount of ``read`` data in KB/s.
* kw/s - The amount of ``written`` data in KB/s.
* wait - The average number of transactions waiting for service. High value of ``wait`` can indicate performance issues.
* wsvc_t - The average service time in wait queue in milliseconds.
* asvc_t - The average service time of active transactions in milliseconds.
* %w - Percentage of time there are transactions waiting for service.
* %b - Percentage of time disk is busy.

How to display device error statistics
######################################

.. code-block:: bash

    [root@node02 ~] iostat -En | grep -i errors
        c1t0d0           Soft Errors: 0 Hard Errors: 0 Transport Errors: 0
        c2t0d0           Soft Errors: 0 Hard Errors: 0 Transport Errors: 0
        c0t0d0           Soft Errors: 0 Hard Errors: 0 Transport Errors: 0
        c0t1d0           Soft Errors: 0 Hard Errors: 0 Transport Errors: 0
        c0t2d0           Soft Errors: 0 Hard Errors: 0 Transport Errors: 0
        c0t3d0           Soft Errors: 0 Hard Errors: 0 Transport Errors: 0
        c0t4d0           Soft Errors: 0 Hard Errors: 0 Transport Errors: 0
        c0t5d0           Soft Errors: 0 Hard Errors: 0 Transport Errors: 0
        c0t6d0           Soft Errors: 0 Hard Errors: 0 Transport Errors: 0
        c0t7d0           Soft Errors: 0 Hard Errors: 0 Transport Errors: 0

.. warning:: Non-zero values may indicate that the device can fail soon. Statistics are counted since the compute node boot time and will not persist across reboots.


How to display the amount of ARC and its effectiveness
######################################################

.. code-block:: bash

    [root@node02 ~] kstat -p zfs:0:arcstats:size \
        | awk '{printf "%s\n", $2 / 1024 / 1024 / 1024, $2}'
    59.9732

* The amount of ARC in GiB.

.. code-block:: bash

    [root@node02 ~] arcstat -f time,arcsz,read,hits,miss,hit%,miss% 1  5
        time  arcsz  read  hits  miss  hit%  miss%
        14:44:32    59G     0     0     0     0      0
        14:44:33    59G    40    40     0   100      0
        14:44:34    59G   377   375     2    99      0
        14:44:35    59G   503   503     0   100      0
        14:44:36    59G   108   108     0   100      0

* time - Time.
* arcsz - ARC size.
* read - Total ARC accesses.
* hits - ARC reads per second.
* miss - ARC misses per second.
* hit% - ARC hit percentage.
* miss% - ARC miss percentage.

How to display information about local disks
############################################

.. code-block:: bash

    [root@node01 ~] diskinfo
    TYPE    DISK                    VID      PID              SIZE          RMV SSD
    SCSI    c4t50000394F8D1162Ad0   TOSHIBA  MG03SCA200       1863.02 GiB   no  no
    SCSI    c10t50000394F8D8201Ad0  TOSHIBA  MG03SCA200       1863.02 GiB   no  no
    SCSI    c8t50000394F8D81CAAd0   TOSHIBA  MG03SCA200       1863.02 GiB   no  no
    SCSI    c11t5000039508CBF8DEd0  TOSHIBA  MG03SCA200       1863.02 GiB   no  no
    SCSI    c9t50000394F8D115F2d0   TOSHIBA  MG03SCA200       1863.02 GiB   no  no
    SCSI    c1t5000039508CBF892d0   TOSHIBA  MG03SCA200       1863.02 GiB   no  no
    SCSI    c2t5000039508CBF89Ad0   TOSHIBA  MG03SCA200       1863.02 GiB   no  no
    SCSI    c3t5000039508CBF856d0   TOSHIBA  MG03SCA200       1863.02 GiB   no  no
    UNKNOWN c6t0d0                  INTEL    SSDSC2BB160G4     149.05 GiB   no  yes
    UNKNOWN c6t1d0                  INTEL    SSDSC2BB160G4     149.05 GiB   no  yes
    UNKNOWN c6t2d0                  KINGSTON SKC300S37A60G      55.90 GiB   no  yes
    USB     c1t0d0                  Kingston DT Micro            7.32 GiB   yes no

- TYPE - The transport type by which the storage device is attached to the host ("UNKNOWN" means that it was not possible to determine the transport type).
- DISK - The name of the device node within the system.
- VID - The vendor identification string reported by the device.
- PID - The product identification string reported by the device.
- SIZE - The device's storage capacity.
- RMV - A field indicating whether the device is removable.
- SSD - A field indicating whether the device is solid-state.
