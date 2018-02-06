.. _dc_monitoring:

Virtual Data Center Monitoring Server
*************************************

Monitoring server resource requirements grow with the increasing number of compute nodes and virtual machines being monitored. Monitoring scalability is limited by hardware, on which the Zabbix server and most importantly its database runs.

The practice has shown that it is not advantageous to build one monolithic monitoring server for the whole infrastructure and that it is better to split the monitoring system onto several smaller servers. Besides that the :ref:`virtual data center <dcs>` represents a suitable logical block it also adds an another layer of security (isolation). The data center administrator gains control over the monitoring system without any access to the central monitoring system.

The *Danube Cloud* management server automatically synchronizes the following objects with the virtual data center monitoring server:

    * :ref:`Virtual servers <vms>` for monitoring from *inside* (agent-based monitoring) and their Monitoring hostgroups. The hostgroup name is prefixed with the virtual data center name.
    * :ref:`User groups <groups>` that are attached to a :ref:`virtual data center <dcs>`. The group name is prefixed with the virtual data center name.
    * :ref:`Users <users>` that are part of a :ref:`user groups <groups>` attached to a :ref:`virtual data center <dcs>` or have the :ref:`DCOwner <roles>` role. The monitoring user has a randomly-generated password.

.. note:: In the default *Danube Cloud* setup, each virtual data center uses the :ref:`main monitoring server <main_monitoring>`.

.. note:: A newly created :ref:`virtual data center <dcs>` inherits all settings (including monitoring settings) from the default *main* data center.

.. warning:: Changing the monitoring server and monitoring settings in the default *main* virtual data center affects the :ref:`internal (main) monitoring server <main_monitoring>` and settings in all virtual data centers. Changing the monitoring server and monitoring settings in other virtual data centers can be used to configure a **dedicated monitoring server for a virtual data center**.


Creation of a Data Center Monitoring Server
###########################################

Immediately after creating a new :ref:`virtual data center <dcs>`, create a new :ref:`virtual server <vm>` with the Linux operating system. When :ref:`adding a primary disk <disk_image_add>`, choose the **esdc-mon** disk image. Please make sure that you are working in the correct virtual data center and replace the IP address or hostname of the central monitoring server with the new monitoring server in the :ref:`virtual data center settings page <dc_monitoring_settings>` (:guilabel:`Datacenter -> Settings -> MON_ZABBIX_SERVER`).

.. note:: The minimal requirements for running a monitoring server are 1x vCPU, 1024 MB RAM, and 15 GB HDD.

.. note:: A virtual data center monitoring server has to be reachable from the network of every monitored virtual server.

.. warning:: The synchronization with a monitoring server is carried out by automated means only for newly created virtual servers. Therefore, it is a good practice to create the virtual data center monitoring server immediately after you create the virtual data center. Existing servers will be synchronized with the monitoring server only after performing the *update* action on a virtual server.

.. warning:: Virtual data centers *main* and *admin* require the :ref:`central (main) monitoring server <main_monitoring>` for correct functioning. Changing monitoring server for these virtual data centers will cause failure of the *Danube Cloud* monitoring system.


Initial Data Center Monitoring Server Configuration
---------------------------------------------------

The initial configuration of a virtual data center monitoring server is the same as the :ref:`configuration of the central monitoring server<monitoring_setup>`.

.. note:: Zabbix is a registered trademark of `Zabbix LLC <http://www.zabbix.com>`_.
