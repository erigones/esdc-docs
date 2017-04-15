ZFS Best Practices
******************

This section summarizes best practices when creating ZFS storage pools.

What to do
##########

* Dedicate **some part of installed memory to ARC**. ARC will intelligently cache data in memory, and speed read operations.

* Use *ECC memory*. ZFS uses memory intensively and stores data in memory. It cannot cope with random bit flips or broken memory slots.

* Use **compression**. Compression may help increase performance dramatically and save some space. *Danube Cloud* has **lz4** compression turned on by default.

* Storage pool should be created using **whole disks** as this will allow ZFS to automatically partition the disk to ensure correct alignment.

* If possible, use a dedicated device for hosting the *ZFS intent log*. This will boost the performance of synchronous writes, and virtual machines in *Danube Cloud* will benefit.

* When not sure which RAID type to use, go for **stripped mirror**, which makes a good trade-off between speed and redundancy. If more capacity is needed, **RAIDZ2** provides an excellent trade-off between capacity and redundancy.

* When using RAIDZ, choose stripe width based on your IOPS needs and the amount of space you are willing to use for parity information.

* For best performance on **random IOPS**, use a small number of disks in each RAID-Z group. E.g, 3-wide RAIDZ1, 6-wide RAIDZ2, or 9-wide RAIDZ3. For even better performance, consider using **mirroring**.

What not to do
##############

* Do not mix **various RAID vdevs in a storage pool**, e.g. do not use mirror combined with RAIDZ. This might lead to poor performance and redundancy levels.

* Do not mix **disks of various speed in a RAID vdev**. The speed of the slowest disk will be a bottleneck, and it may degrade the performance of the whole storage pool.

* Do not mix **disks of various size in a RAID vdev** as this might lead to space loss.

* Do not **partition a device used for hosting ZFS intent log**, use the whole device every time.
