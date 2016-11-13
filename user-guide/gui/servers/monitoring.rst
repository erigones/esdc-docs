Virtual Server Monitoring
#########################

The monitoring graphs show the current and historic utilization of virtual server's resources from the perspective of the compute node.

=============================== ================
:ref:`Access Permissions <acl>`
------------------------------- ----------------
*SuperAdmin*                    read-only
*DCAdmin*                       read-only
*VmOwner*                       read-only
=============================== ================


CPU Graphs
==========

* **CPU usage** - Total compute node CPU consumed by the virtual machine.

    .. image:: img/monitoring_cpu_usage.png

* **CPU wait time** - Total amount of time spent in CPU run queue by the virtual machine.

    .. image:: img/monitoring_cpu_wait_time.png

* **CPU load** - One-minute load average.

    .. image:: img/monitoring_cpu_load.png

Memory Graphs
=============

* **Memory usage** - Total compute node physical memory consumed by the virtual machine.

    .. image:: img/monitoring_memory_usage.png

* **Swap usage** - Total compute node swap space used by the virtual machine.

    .. image:: img/monitoring_swap_usage.png

NIC Graphs
==========

* **NIC bandwidth** - The amount of received and sent network traffic through the virtual network interface.

    .. image:: img/monitoring_nic_bandwidth.png

* **NIC packets** - The amount of received and sent packets through the virtual network interface.

    .. image:: img/monitoring_nic_packets.png

Disk Graphs
===========

* **Disk throughput** - The amount of written and read data on the virtual hard drive.

    .. image:: img/monitoring_disk_throughput.png

* **Disk I/O** - The amount of write and read I/O operations performed on the virtual hard drive.

    .. image:: img/monitoring_disk_io.png

Aggregated Disk Layer Graphs
============================

* **VM disk logical throughput** - Aggregated disk throughput on the logical layer (with acceleration mechanisms included).

    .. image:: img/monitoring_vm_disk_logical_io.png

* **VM disk logical I/O** - Aggregated amount or read and write I/O operations on the logical layer (with acceleration mechanisms included).

    .. image:: img/monitoring_vm_disk_logical_throughput.png

* **VM disk physical throughput** - Aggregated disk throughput on the physical (disk) layer.

    .. image:: img/monitoring_vm_disk_operations.png

* **VM disk physical I/O** - Aggregated amount of read and write I/O operations on the physical (disk) layer.

    .. image:: img/monitoring_vm_disk_physical_io.png

* **VM disk I/O operations by latency** - Aggregated amount of disk I/O operations by latency on the logical layer (with acceleration mechanisms included).

    .. image:: img/monitoring_vm_disk_physical_throughput.png

