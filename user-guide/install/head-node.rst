.. _installation_hn:

Head Node Installation
**********************

.. _hn_boot_loader:

* Boot loader.

    .. image:: img/hn-00-grub.png

* Welcome screen.

    .. image:: img/hn-01-welcome.png

* Setting the name of the physical data center.

    .. image:: img/hn-03-dc-name.png

* Hypervisor (**admin**) network setup.

    .. image:: img/hn-04-network-ip.png

    * Choosing a network card.
    * Head node IP address.
    * Network mask.
    * Network gateway.
    * Primary DNS server.
    * Secondary DNS server.
    * Domain name.
    * DNS search domain.

    .. image:: img/hn-06-dns.png

    .. warning:: The Compute Node hostname cannot be changed after install.

* IP address configuration of the central web management server and choosing a configuration master password.

    .. note:: Please keep the configuration master password safe and confidential. It will be required during :ref:`compute node installation <installation_cn>`.

    .. image:: img/hn-07-mgmt.png

* Choosing head node's root password.

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

* Configuring Administrator's email address.

    .. image:: img/hn-11-admin-email.png

* Final overview of all information required for setting up the main compute node.

    .. image:: img/hn-12-summary.png

* Installation of the *Danube Cloud* software.

    .. note:: During the installation process of *Danube Cloud*, files are being copied from the USB flash drive to the primary data storage which usually takes about 5 to 30 minutes.

* Log in to the Web Management Server.

    .. note:: Login and password to the web management are **admin** and **changeme**. Please change the password as soon as possible using the *change password* form in the user profile section.

.. seealso:: Please have a look at the :ref:`post-installation section in this chapter <first_steps>`.

.. seealso:: How to change the password used for accessing the Compute Node is described in the :ref:`root password change <root_password_change>` section.
