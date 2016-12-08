.. _vm_monitoring:

Virtual Server Monitoring
*************************

Virtual Server Monitoring Synchronization with the Monitoring Server
####################################################################

* A virtual server will synchronize with the monitoring server for the first time after the *deploy* process finishes.
* A virtual server will synchronize with the monitoring server every time during an *update* action.
* Disabling monitoring in virtual server details will set the virtual server to an *unmonitored* state and no new data will be collected.
* Historical monitoring data is preserved even after deleting a virtual server from the compute node with the *destroy* action.
* Historical monitoring data is deleted after complete removal of a virtual server with *delete* action.

.. note:: Virtual servers created during the time the data center monitoring was completely disabled will not be monitored. Internal monitoring of such virtual servers can be turned on via the API interface.

    .. code-block:: bash

      [user@laptop ~] es set /vm/www.test.tld/define -dc mydc -monitored_internal true


.. _dc_vm_monitoring_advanced:

Advanced Settings of Virtual Data Center Monitoring
###################################################

.. seealso:: Detailed list of virtual data center monitoring settings can be found in the :ref:`data center settings section <dc_monitoring_setup>`.


Dynamic Assignment of Monitoring Templates and Host Groups
==========================================================

* **MON_ZABBIX_HOSTGROUPS_VM** - List of other existing Zabbix host groups, which will be used for all monitored servers in a virtual data center. Available placeholders are:

    * ``{ostype}`` - ID type of the operating system (1 - *Linux VM*, 2 - *SunOS VM*, 3 - *BSD VM*, 4 - *Windows VM*, 5 - *SunOS Zone*).
    * ``{ostype_text}`` - The type of the operating system with lowercase letters and spaces replaced with underscores (*linux_vm*, *sunos_vm*, *bsd_vm*, *windows_vm*, *sunos_zone*).
    * ``{disk_image}`` - The name of the disk image or an empty string.
    * ``{disk_image_abbr}`` - The name of the disk image, which is automatically changed in a way that version is removed (everything after the first comma, including comma) or an empty string.
    * ``{dc_name}`` - The name of a virtual data center to which virtual server belongs.

* **MON_ZABBIX_HOSTGROUPS_VM_ALLOWED** - List of Zabbix host groups that can be used by virtual servers in a virtual data center. Available placeholders are the same as for **MON_ZABBIX_HOSTGROUPS_VM**.

* **MON_ZABBIX_TEMPLATES_VM** - List of existing Zabbix templates, which will be used for all monitored servers in a virtual data center. Available placeholders are:

    * ``{ostype}`` - ID type of the operating system (1 - *Linux VM*, 2 - *SunOS VM*, 3 - *BSD VM*, 4 - *Windows VM*, 5 - *SunOS Zone*).
    * ``{ostype_text}`` - The type of the operating system with lowercase letters and spaces replaced with underscores (*linux_vm*, *sunos_vm*, *bsd_vm*, *windows_vm*, *sunos_zone*).
    * ``{disk_image}`` - The name of the disk image or an empty string.
    * ``{disk_image_abbr}`` - The name of the disk image, which is automatically changed in a way that version is removed (everything after first comma, including comma) or an empty string.
    * ``{dc_name}`` - The name of a virtual data center to which virtual server belongs.

* **MON_ZABBIX_TEMPLATES_VM_ALLOWED** - List of Zabbix templates that can be used by servers in a virtual data center. Available placeholders are the same as for **MON_ZABBIX_TEMPLATES_VM**.

* **MON_ZABBIX_TEMPLATES_VM_NIC** - List of Zabbix templates that will be used for all monitored servers, for every virtual NIC of a server. Available placeholders are the same as for **MON_ZABBIX_TEMPLATES_VM** + following placeholders:

    * ``{nic_id}`` - ID of a virtual network interface.

* **MON_ZABBIX_TEMPLATES_VM_DISK** - List of Zabbix templates that will be used for all monitored servers, for every virtual disk of a server. Available placeholders are the same as for **MON_ZABBIX_TEMPLATES_VM** + following placeholders:

    * ``{disk_id}`` - ID of a virtual hard disk.

Example
~~~~~~~

An example of dynamic variables for generating monitoring host groups and monitoring templates for virtual server with *Linux*-based operating system created from *rhel-6.6-3* disk image with the following monitoring data center settings:

* **MON_ZABBIX_HOSTGROUP_VM** - ``GroupA``
* **MON_ZABBIX_HOSTGROUPS_VM** - ``Group{ostype},Group_{disk_image_abbr}``
* **MON_ZABBIX_TEMPLATES_VM** - ``t_TemplateA,t_Template{ostype},t_Template_{disk_image_abbr}``

The monitored server will be assigned into following host groups: *GroupA*, *Group1*, *Group_rhel*.
The server will have the following monitoring templates assigned: *t_TemplateA*, *t_Template1*, *t_Template_rhel*.


.. note:: Zabbix is a registered trademark of `Zabbix LLC <http://www.zabbix.com>`_.
