.. _storage_diagnostic:

Storage Pool Troubleshooting
****************************

How to display storage pool status
##################################

.. code-block:: bash

    [root@node01 ~] zpool status
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

    [root@node01 ~] zpool list
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

    [root@node01 ~] zfs list zones
    NAME    USED  AVAIL  REFER  MOUNTPOINT
    zones   132G  1.44T   643K  /zones

How to display the amount of used space on a ZFS dataset/volume
###############################################################

.. code-block:: bash

    [root@node01 ~] zfs list -o space zones/...-disk0
    NAME             AVAIL   USED  USEDSNAP  USEDDS  USEDREFRESERV  USEDCHILD
    zones/...-disk0  1.46T  22.2G      162M   2.14G          19.9G          0


How to display compression effectiveness
########################################

.. code-block:: bash

    [root@node01 ~] zfs get compressratio zones/...-disk0
    NAME             PROPERTY         VALUE  SOURCE
    zones/...-disk0  compressratio    3.64x     -


How to display I/O operations in the storage pool by device
###########################################################

.. code-block:: bash

    [root@node01 ~] zpool iostat -v zones 5
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

    [root@node01 ~] iostat -xzn 1
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


How to observe I/O activity per virtual machine
###############################################

* ``vfsstat`` - VFS read and write activity; includes reads and writes which may use the filesystem´s cache.

    .. code-block:: bash

        [root@node01 ~] # vfsstat -M -Z 5
        r/s   w/s  Mr/s  Mw/s ractv wactv read_t writ_t  %r  %w   d/s  del_t zone
        1425.6   6.2   0.4   0.0   0.0   0.0    2.2    9.4   0   0   0.0    0.0 global (0)
        0.0   0.0   0.0   0.0   0.0   0.0    0.0    0.0   0   0   0.0    0.0 3bb67ec6 (4)
        0.0   0.0   0.0   0.0   0.0   0.0    0.0    0.0   0   0   0.0    0.0 3cc5ac84 (3)
        0.2   7.8   0.0   0.0   0.0   0.1 23982.7 15663.6   0   3   1.4   10.0 e1273324 (20)
        0.0   1.4   0.0   0.0   0.0   0.0    0.0 22972.0   0   1   0.0    0.0 ec4e28bb (22)
        2412.3  13.5   0.5   0.4   0.0   0.0    2.4   40.0   0   0   0.0    0.0 c006ad9f (5)
        9.2   2.8   0.0   0.0   0.0   0.0    3.9   25.6   0   0   0.0    0.0 11a6bfd7 (8)
        6.6   1.2   0.0   0.0   0.0   0.0    3.7   38.2   0   0   0.0    0.0 4aa8ad96 (36)
        0.2   0.0   0.0   0.0   0.0   0.0   15.4    0.0   0   0   0.0    0.0 d7ba84c1 (16)
        5.4   1.8   0.1   0.0   0.0   0.0    9.3   60.3   0   0   0.0    0.0 06308cc6 (110)
        0.0   2.2   0.0   0.0   0.0   0.0    0.0 10571.3   0   1   0.0    0.0 8517ad37 (101)
        0.0   0.0   0.0   0.0   0.0   0.0    0.0    0.0   0   0   0.0    0.0 db2c8319 (31)
        0.0   0.0   0.0   0.0   0.0   0.0    0.0    0.0   0   0   0.0    0.0 f7f81a9b (45)
        3.2   7.8   0.1   0.2   0.0   0.1 1656.5 18943.7   0   3  11.4   13.3 a28faa4d (59)
        0.2   0.0   0.0   0.0   0.0   0.0   29.4    0.0   0   0   0.0    0.0 2490a976 (103)

    * r/s - reads per second.
    * w/s - writes per second.
    * kr/s - kilobytes read per second.
    * kw/s - kilobytes written per second.
    * ractv - average number of read operations actively being serviced by the VFS layer.
    * wactv - average number of write operations actively being serviced by the VFS layer.
    * read_t - average VFS read latency, in microseconds.
    * writ_t - average VFS write latency, in microseconds.
    * %r - percent of time there is a VFS read operation pending.
    * %w - percent of time there is a VFS write operation pending.
    * d/s - VFS operations per second delayed by the ZFS I/O throttle.
    * del_t - average ZFS I/O throttle delay, in microseconds.

* ``ziostat`` - ZFS read I/O activity; displays latency of I/O operations happening on the physical disk layer.

    .. code-block:: bash

        [root@node01 ~] # ziostat -M -Z 5
        0.8    0.0    0.0   17.0   19.6   0 global (0)
        0.0    0.0    0.0    0.0    0.0   0 3bb67ec6 (4)
        0.0    0.0    0.0    0.0    0.0   0 3cc5ac84 (3)
        0.0    0.0    0.0    0.0    0.0   0 e1273324 (20)
        0.0    0.0    0.0    0.0    0.0   0 ec4e28bb (22)
        0.0    0.0    0.0    0.0    0.0   0 c006ad9f (5)
        0.0    0.0    0.0    0.0    0.0   0 11a6bfd7 (8)
        0.0    0.0    0.0    0.0    0.0   0 4aa8ad96 (36)
        0.0    0.0    0.0    0.0    0.0   0 d7ba84c1 (16)
        0.0    0.0    0.0    0.0    0.0   0 06308cc6 (110)
        0.0    0.0    0.0    0.0    0.0   0 8517ad37 (101)
        0.0    0.0    0.0    0.0    0.0   0 db2c8319 (31)
        0.0    0.0    0.0    0.0    0.0   0 f7f81a9b (45)
        5.4    0.0    0.1    0.0   13.8   0 a28faa4d (59)
        0.0    0.0    0.0    0.0    0.0   0 2490a976 (103)

    * r/s - reads per second.
    * kr/s - kilobytes read per second.
    * actv - average number of ZFS read I/O operations being handled by the disk.
    * wsvc_t - average wait time per I/O, in milliseconds.
    * asvc_t - average disk service time per I/O, in milliseconds.
    * %b - percent of time there is  an I/O operation pending.

