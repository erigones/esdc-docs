.. _installation_cn:

Compute Node Installation
*************************

.. note:: There are :ref:`two types of installation media<cn_image>` and the installation steps documented below are slightly different for both of them. The first compute node installation media should be used only for the first compute node. All other physical servers should be installed using the smaller compute node USB image.

.. _cn_boot_loader:

* Boot loader.

    .. image:: img/install-00-grub.png

* Welcome screen.

    .. image:: img/install-01-welcome.png

* Setting the name of the physical data center (**first compute node** only).

    .. image:: img/install-02hn-dc-info.png

* Compute node's networking configuration.

    .. image:: img/install-03-networking-info.png

    .. image:: img/install-04-networking-admin.png

    .. image:: img/install-05-networking-dns.png

    * Choosing a network card.
    * Admin network IP address.
    * Admin network mask.
    * Admin network VLAN ID.
    * Default gateway IP address.
    * Primary DNS server.
    * Secondary DNS server.
    * DNS search domain.
    * NTP server IP address or hostname.

* Choosing the installation type:

    .. image:: img/install-06-hdd.png

    * *Booting from USB (default).* This is the preferred installation method. The hard drives are only used for storing virtual machines and other user data. The hypervisor is loaded into RAM from the USB flash drive. The hypervisor (kernel) can be upgraded by swapping the USB media and rebooting the system. The USB media is required for every boot of the compute node.

    * *Installation to hard drive.* This installation type is required when using advanced storage components connected via fiber channel or iSCSI. The contents of the USB flash drive are copied to the hard drives. The USB media should be removed after the installation is finished and before the first reboot.

* Creating the primary data storage (*zones* pool).

    .. image:: img/install-07-zpool.png

    * An optimal disk array profile is chosen automatically based on the information gathered about available local disks. The storage can be configured manually, however, this method is only recommended for more experienced users.

    .. seealso:: A more detailed explanation of :ref:`disk arrays <storage>` and :ref:`disk redundancy <storage_redundancy>` can be found in a separate chapter.

* Compute node OS configuration.

    .. image:: img/install-08-system.png

    * Choosing compute node's root password.
    * System hostname - fully qualified domain name.

    .. warning:: The Compute Node hostname cannot be changed after install.

* Configuration of Danube Cloud management services:

   - **First compute node**

        .. image:: img/install-09hn-dc-mgmt.png

        * IP address configuration of the central web management server.
        * Choosing a configuration master password.


   - **Any other compute node**

        .. image:: img/install-09cn-dc-mgmt.png

        * IP address configuration of the configuration database server (cfgdb).
        * Entering your configuration master password.

* Configuring Administrator's email address (**first compute node** only).

    .. image:: img/install-10hn-admin-email.png

* Final overview of all information required for setting up the compute node.

    .. image:: img/install-11-summary.png

* Installation of the *Danube Cloud* compute node and management software.

    .. note:: During the installation process of *Danube Cloud*, files are being copied from the USB flash drive to the primary data storage which usually takes about 5 to 30 minutes.

* After a successful installation, please log in to the Web Management Server.

   - **First compute node**: Login and password to the web management are **admin** and **changeme**. Please change the password as soon as possible using the *change password* form in the user profile section.

        .. seealso:: Please have a look at the :ref:`post-installation section in this chapter <first_steps>`.

   - **Any other compute node**: The compute node will appear in the web interface of the central web management server automatically.


.. seealso:: How to change the password used for accessing the Compute Node is described in the :ref:`root password change <root_password_change>` section.
