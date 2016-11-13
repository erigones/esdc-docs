.. _main_monitoring:

Central Monitoring Server
*************************

The Central (Main) Monitoring Server is a part of *Danube Cloud* :ref:`head node installation <admin_dc>`.

.. note:: In the default *Danube Cloud* setup, each virtual data center uses the central (main) monitoring server.

.. note:: A newly created :ref:`virtual data center <dcs>` inherits all settings (including monitoring settings) from the default *main* data center.

.. warning:: Changing the monitoring server and monitoring settings in the default *main* virtual data center affects the **internal (main) monitoring server** and settings in all virtual data centers. Changing the monitoring server and monitoring settings in other virtual data centers can be used to configure a dedicated :ref:`monitoring server for a virtual data center <dc_monitoring>`.


.. _monitoring_setup:

Initial Configuration
#####################

First Login into Zabbix
=======================

The Zabbix web interface is available at http://zabbix_ip.
The default username is ``Admin`` and the password was auto-generated and displayed upon successful :ref:`installation of the head node <installation_hn>`. The *Admin* password may be also visible as a metadata (``zabbix_admin_password``) of the **mon01** virtual server  in the :ref:`Admin virtual data center <admin_dc>`.


Default Users
=============

The monitoring server has two preconfigured Zabbix users and one system user. Their passwords were auto-generated during head node installation or during the build process of *Danube Cloud*.

* **Admin** - A Zabbix account, which is used for monitoring system configuration.

* **provisioner** - A Zabbix account, which is used for communication between the *Danube Cloud* and the Zabbix API. This account does not have access to the web frontend.

    .. warning:: Changing *provisioner*'s password in Zabbix also requires changing the *MON_ZABBIX_PASSWORD* in all affected :ref:`virtual data centers <dc_monitoring_settings>` (``Datacenter -> Datacenter -> default -> Edit more settings -> Show advanced settings -> MON_ZABBIX_PASSWORD``).

* **root** - A system superuser account, which can be used for remote administration over SSH. The password for the **root** user was auto-generated during the build process of the installation image. The **root** account should have the head node's public SSH key set and therefore should be accessible from the head node via SSH.


Monitoring Server Factory Settings
==================================

.. warning:: The change of factory settings can seriously damage the correct functioning of the monitoring and alerting system. It is not recommended to change these settings and also `Erigones <http://www.erigones.com>`__ does not take any responsibility for damage caused by changing these settings.

Hosts
+++++

All synchronized servers are created automatically and any manipulation with them in Zabbix is forbidden. Hosts are divided into several categories:

* Compute nodes
* Virtual machines

    * Virtual servers without monitoring agent (agentless)
    * Virtual servers with monitoring agent

.. note:: Virtual servers can be monitored with and/or without an agent. For this reason, two hosts are created in Zabbix. Host names prefixed with an underscore ``_`` character are monitored from the compute node (agentless monitoring).

Host Groups
+++++++++++

The following host groups are required for the correct functioning of the monitoring system:

* Compute nodes
* Notifications
* Virtual machines
* Templates

Templates
+++++++++

The following Zabbix monitoring templates are required for the correct functioning of the monitoring and it is forbidden to use them:

* t_icmp
* t_zabbix-agent
* t_erigones-zone
* t_erigonos
* t_solaris_disk
* t_linux
* t_linux-disk
* t_svc-api
* t_svc-cache
* t_svc-db
* t_svc-dns
* t_svc-erigonesd-compute
* t_svc-erigonesd-mgmt
* t_svc-gui
* t_svc-img
* t_svc-mq
* t_svc-remote-console
* t_svc-sio
* t_svc-web-proxy
* t_svc-web-static
* t_vm_cpu
* t_vm_disk_latency
* t_vm_disk_space
* t_vm_memory
* t_vm_zone_cpu
* t_vm_zone_dataset
* t_vm_zone_vfs
* t_vm_zone_zfs
* t_vm_kvm_disk0_io
* t_vm_kvm_disk1_io
* t_vm_kvm_disk2_io
* t_vm_kvm_disk3_io
* t_vm_network_net0
* t_vm_network_net1
* t_vm_network_net2
* t_vm_network_net3
* t_vm_network_net4
* t_vm_network_net5
* t_vm_network_net6
* t_vm_network_net7
* t_zfs_io_throttle
* t_zfs_arc
* t_zfs_l2arc
* t_zabbix-db
* t_zabbix-agent
* t_zabbix-proxy
* t_zabbix-server
* t_role-db
* t_role-dns
* t_role-img
* t_role-mgmt
* t_role-mon
* t_role-compute

The following Zabbix templates can be used for other monitoring purposes, but cannot be changed:

* t_icmp
* t_zabbix-agent
* t_erigones-zone
* t_linux
* t_linux-disk
* t_zabbix-proxy
* t_zabbix-server

.. note:: Upon request, `Erigones <http://www.erigones.com>`__ is able to create monitoring templates for monitoring of specific hardware configuration.

IT Services
+++++++++++

``IT Services -> Compute Nodes`` is used for calculating compute node's SLA.


.. note:: Zabbix is a registered trademark of `Zabbix LLC <http://www.zabbix.com>`_.
