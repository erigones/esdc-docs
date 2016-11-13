Hardware Requirements
*********************

Compute Node (CN)
#################

For using the *Danube Cloud* software in a production environment, we recommend using servers from IBM, Dell, HP, Cisco or Oracle server manufactures in order to achieve 100% hardware compatibility.

:download:`Complete list of supported hardware. <hcl.html>`

If you didn't find your hardware in the list above, send an email with complete hardware configuration to ``hcl@erigones.com`` for hardware compatibility verification.


Processor (CPU)
###############

*Danube Cloud* supports **Intel®** processors with the **VT-x** (Virtualization Technology eXtensions) and **EPT** (Extended Page Tables) support. Current and complete list of supported processors is available directly on the Intel® website http://ark.intel.com/Products/VirtualizationTechnology.


Memory (RAM)
############

A compute node requires a minimum of **4 GB of RAM**. The system memory can be used not only to create virtual servers, but also for operating ZFS file system. This dramatically increases the speed of read operations from hard drives (ARC).

PCI Devices (PCI)
#################

Servers using *Danube Cloud* are required to have at least **one network interface card** and a **disk controller**.


Network
#######

.. note:: The installation procedure requires **Internet access** and at least one **DNS server** accessible from the *admin* network, which is used for compute nodes and central web management intercommunication purposes.

Switch
======

*Danube Cloud* requires a 1 GbE or 10 GbE local area network (LAN). Network switches must support the IEEE 802.1Q (VLAN) standard. To achieve high availability and network aggregation, the LACP (IEEE 802.3ad) standard is used and network switches must be stackable.

.. note:: The number of virtual networks used in a data center is limited by the type of network switches used. The information about maximum number of VLANs is provided by the manufacturer of the network equipment. The usual number of supported VLANs ranges from 1024 to 4096.


Router / Firewall / VPN
=======================

* **Access Zone** - software router (Solaris zone).
    * IPFILTER (IPF)

        * Router
        * Firewall

    * OpenVPN
    * Monitoring

    .. seealso:: A guide on how to create and use :ref:`access zones <access_zone>`.

* **Router / Firewall as Virtual Server** - software router (Linux/BSD/Windows).

    .. note:: For a router in a virtual server or zone, you must enable IP and MAC spoofing on a virtual network interface.

* **External hardware or software router**


Data Storage
############

Local or Direct-attached Storage (DAS)
======================================

Direct-attached storage is made of local data storage devices (typically hard drives) that are grouped together into disk arrays using the advanced file system and volume manager ZFS.

* SATA
* SAS
* SSD

    .. note:: Solid-state disks (SSD) can be used not only for storing data, but also 

        * as a cache for frequent synchronous disk writes of smaller data blocks (ZIL)
        * and for a rapid increase in speed of read operations of frequently used data (L2ARC).


Storage Area Network (SAN)
==========================

* iSCSI (1Gb/10Gb Ethernet)


.. _raid_types:

Disk Arrays (RAID)
==================

* RAID0
* RAID1
* RAID10 - provides the highest speed at random reads of small files.
* RAIDZ (RAID5) - provides maximum usability of the storage capacity as well as protection against the failure of one disk.
* RAIDZ2 (RAID6) - provides maximum usability of the storage capacity as well as protection against the failure of two disks. The performance of the array is the same as with RAIDZ.
* RAIDZ3 - provides maximum usability of the storage capacity as well as protection against the failure of three disks. The performance of the array is the same as with RAIDZ.

.. seealso:: A more detailed explanation of :ref:`disk arrays <storage>` and :ref:`disk redundancy <storage_redundancy>` can be found in a separate chapter.

* Hardware RAID

    .. warning:: When using a hardware RAID, disks must be monitored by an external monitoring system and/or by utilities provided by the OEM. The use of ZFS provides an opportunity to use all of the compute node's resources for a maximum IO performance and rigorous data protection. For disk controllers that are not able to provide direct access to hard drives (disk pass-through), use of RAID0 for every hard drive is recommended and to build a ZFS zpool on top of them.


Unsupported Hardware
********************

.. warning:: Currently, USB version 3 is not supported, and you may have to disable USB 3.0 support in the BIOS configuration.

.. warning:: Some Intel® processors, which are using the C-States feature, can cause an error that may seriously endanger the run of a working compute node. The error is treated in the system, but you are advised to disable C-States in the BIOS configuration.

