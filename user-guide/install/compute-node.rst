.. _installation_cn:

Compute Node Installation
*************************

.. _cn_boot_loader:

* Boot loader.

    .. image:: img/cn-00-grub.png

* Welcome screen.

    .. image:: img/hn-01-welcome.png

* Hypervisor (**admin**) network setup.

    .. image:: img/cn-04-network-ip.png

    * Choosing a network card.
    * Head node IP address.
    * Network mask.
    * Network gateway.
    * Primary DNS server.
    * Secondary DNS server.
    * Domain name.
    * DNS search domain.

    .. image:: img/cn-06-dns.png

    .. warning:: The Compute Node hostname cannot be changed after install.

* IP address configuration of the configuration database server (cfgdb) and entering your configuration master password.

    .. note:: You have chosen your configuration master password during :ref:`head node installation <installation_hn>`.

    .. image:: img/cn-07-cfgdb.png

* Choosing compute node's root password.

    .. image:: img/hn-08-root-pw.png

* Choosing the installation type:

    .. image:: img/hn-09-hdd-install.png

    * *Booting from USB (default).* This is the preferred installation method. The hard drives are only used for storing virtual machines and other user data. The hypervisor is loaded into RAM from the USB flash drive. The hypervisor (kernel) can be upgraded by swapping the USB media and rebooting the system. The USB media is required for every boot for this installation method.

    * *Installation to hard drive.* This installation type is required when using advanced storage components connected via fiber channel or iSCSI. The contents of the USB flash drive are copied to the hard drives. The USB media should be removed after the installation is finished and before the first reboot.

        .. note:: In case the USB drive was not removed before the first reboot, the machine needs to be rebooted again without the USB drive plugged in.

* Creating a primary data storage (*zones* pool).

    .. note:: An optimal disk array profile is chosen automatically based on the information gathered about available local disks. The storage can be configured manually, however, this method is only recommended for more experienced users.

    .. seealso:: A more detailed explanation of :ref:`disk arrays <storage>` and :ref:`disk redundancy <storage_redundancy>` can be found in a separate chapter.

    .. image:: img/hn-10-zpool.png

* Final overview of all information required for setting up the compute node.

    .. image:: img/cn-12-summary.png

* After a successful installation, the compute node will appear in the web interface of the central web management server.

.. seealso:: How to change the password used for accessing the compute node is described in the :ref:`root password change <root_password_change>` section.
