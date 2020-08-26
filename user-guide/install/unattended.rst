.. _unattended_installation:

Unattended Compute Node Installation
************************************

.. note:: The unattended compute node installation is supported from *Danube Cloud* version 3.0.

The compute node installation can be automated by placing an ``answers.json`` file into the ``/private`` folder on the :ref:`newly created USB flash drive<usb_key_howto>`. The ``/private/answers.json`` should contain a flat JSON object with all the configuration values that should be automatically used as answers by the installer. If an answer is missing or invalid, the installer will stop at the question and wait for a valid answer.

.. note:: Since version `4.3` the installer always saves the ``/usbkey/answers.json`` with all install answers (passwords are scrambled) and you can use it to replicate the install.

.. code-block:: json
    :caption: Example answers.json file

    {
        "config_console": "vga",
        "skip_instructions": true,
        "simple_headers": true,
        "accept_eula": false,
        "advanced_install": false,
        "datacenter_name": "My datacenter",
        "etherstubs": "",
        "admin_ip": "192.168.12.10",
        "admin_netmask": "255.255.255.0",
        "admin_gateway": "192.168.12.1",
        "admin_vlan_id": "",
        "deploy_opnsense": "false",
        "add_nictags": true,
        "external_add_nictag": true,
        "external_add_ip": false,
        "external_preserve_mac": false,
        "internal_add_nictag": false,
        "storage_add_nictag": false,
        "headnode_default_gateway": "192.168.12.1",
        "dns_resolver1": "<default>",
        "dns_resolver2": "<default>",
        "dns_search": "<default>",
        "ntp_host": "<default>",
        "skip_ntp_check": false,
        "install_to_hdd": false,
        "disk_layout": "<default>",
        "root_password": "Passw0rd",
        "hostname": "<default>",
        "remote_node": false,
        "mgmt_admin_ip": "192.168.12.101",
        "cfgdb_admin_ip": "192.168.12.105",
        "esdc_install_password": "nbusr123",
        "admin_email": "root@example.com",
        "skip_final_confirm": true,
        "auto_reboot": "false"
    }

.. code-block:: json
    :caption: Another example answers.json file with OPNSense VM

    {
      "skip_instructions": "true",
      "simple_headers": "true",
      "config_console": "vga",
      "accept_eula": "true",
      "advanced_install": "1",
      "datacenter_name": "MyDC",
      "admin_nic": "00:0c:29:73:af:1b",
      "admin_ip": "10.11.11.11",
      "admin_netmask": "255.255.255.0",
      "admin_vlan_id": "11",
      "add_nictags": "1",
      "external_add_nictag": "true",
      "external_nic": "00:0c:29:73:af:1b",
      "external_add_ip": "true",
      "external_ip": "10.100.10.167",
      "external_netmask": "255.255.255.0",
      "external_vlan_id": "",
      "external_preserve_mac": "false",
      "internal_add_nictag": "true",
      "internal_nic": "00:0c:29:73:af:1b",
      "internal_add_ip": "false",
      "storage_add_nictag": "false",
      "deploy_opnsense": "1",
      "opnsense_admin_ip": "10.11.11.1",
      "opnsense_external_ip": "dhcp",
      "opnsense_external_mac": "auto",
      "headnode_default_network": "external",
      "dns_resolver1": "8.8.8.8",
      "dns_resolver2": "8.8.4.4",
      "dns_search": "local",
      "ntp_host": "0.smartos.pool.ntp.org",
      "install_to_hdd": "true",
      "disk_layout": "single",
      "root_password": "Passw0rd",
      "hostname": "n01.local",
      "mgmt_admin_ip": "10.11.11.111",
      "esdc_install_password": "Passw0rd",
      "admin_email": "root@example.com",
      "skip_final_summary": "true",
      "skip_final_confirm": "true",
      "auto_reboot": "false"
    }



.. list-table:: answers.json options
    :header-rows: 1
    :stub-columns: 0

    * - Installer option
      - Note

    * - :ref:`config_console<cn_boot_loader>`
      - The boot console selected in the boot loader menu (``vga``, ``ttya``, ``ttyb``, ``ttyc``).

    * - :ref:`skip_instructions<cn_install_welcome>`
      - default: ``false``
    * - :ref:`simple_headers<cn_install_welcome>`
      - default: ``false``
    * - :ref:`accept_eula<cn_install_welcome>`
      - default: ``false``

    * - :ref:`advanced_install<cn_install_advanced>`
      - default: ``false``; If ``false``, some options in the `answers.json` file may be ignored.

    * - :ref:`datacenter_name<cn_install_datacenter>`
      -

    * - :ref:`etherstubs<cn_install_networking>`
      - default: ``(empty)``; Comma-separated list of etherstub names.
    * - :ref:`admin_nic<cn_install_networking>`
      -
    * - :ref:`admin_ip<cn_install_networking>`
      -
    * - :ref:`admin_netmask<cn_install_networking>`
      - default: ``255.255.255.0``
    * - :ref:`admin_vlan_id<cn_install_networking>`
      - default: ``0``
    * - :ref:`add_nictags<cn_install_networking>`
      - default: ``false``; Must be ``true`` if other NIC tags should be configured.
    * - :ref:`<nictag>_add_nictag<cn_install_networking>`
      - default: ``false``; Valid values for ``<nictag>`` are: ``external``, ``internal``, ``storage``.
    * - :ref:`<nictag>_nic<cn_install_networking>`
      - Requires ``<nictag>_add_nictag`` to be ``true``.
    * - :ref:`<nictag>_add_ip<cn_install_networking>`
      - default: ``false``; Requires ``<nictag>_add_nictag`` to be ``true``.
    * - :ref:`<nictag>_ip<cn_install_networking>`
      - Requires ``<nictag>_add_nictag`` to be ``true``.
    * - :ref:`<nictag>_netmask<cn_install_networking>`
      - default: ``255.255.255.0``; Requires ``<nictag>_add_nictag`` to be ``true``.
    * - :ref:`<nictag>_vlan_id<cn_install_networking>`
      - default: ``0``; Requires ``<nictag>_add_nictag`` to be ``true``.
    * - :ref:`<nictag>_preserve_mac<cn_install_networking>`
      - default: ``false``; Requires ``<nictag>_add_nictag`` to be ``true``.

    * - :ref:`deploy_opnsense<cn_install_opnsense>`
      - default: no
    * - :ref:`opnsense_external_ip<cn_install_opnsense>`
      - ``dhcp`` or `IP address`
    * - :ref:`opnsense_external_mac<cn_install_opnsense>`
      - ``auto`` or `MAC address` or ``node`` (take node's MAC from external NIC)
    * - :ref:`headnode_default_network<cn_install_opnsense>`
      - ``admin`` or ``external``, related to OPNSense VM

    * - :ref:`headnode_default_gateway<cn_install_networking>`
      - default: first IP address in the admin subnet
    * - :ref:`admin_gateway<cn_install_networking>`
      - default: first IP address in the admin subnet

    * - :ref:`dns_resolver1<cn_install_networking>`
      - default: ``8.8.8.8``
    * - :ref:`dns_resolver2<cn_install_networking>`
      - default: ``8.8.4.4``
    * - :ref:`dns_search<cn_install_networking>`
      - default: ``local``
    * - :ref:`ntp_host<cn_install_networking>`
      - default: ``0.smartos.pool.ntp.org``
    * - :ref:`skip_ntp_check<cn_install_networking>`
      - default: ``false``

    * - :ref:`install_to_hdd<cn_install_hdd>`
      - default: ``false``
    * - :ref:`disk_layout<cn_install_storage>`
      - The ``default`` value will automatically confirm the suggested disk layout. Possible values are: ``default``, ``single``, ``mirror``, ``raidz1``, ``raidz2``, ``raidz3``, ``manual``.

    * - :ref:`root_password<cn_install_system>`
      -
    * - :ref:`hostname<cn_install_system>`
      - default: ``node02.<dns_search>`` or ``node01.<dns_search>`` for the first compute node

    * - :ref:`mgmt_admin_ip<cn_install_esdc>`
      - default: ``admin_ip + 1``; Used only for the first compute node.
    * - :ref:`cfgdb_admin_ip<cn_install_esdc>`
      - Used for any other than the first compute node.
    * - :ref:`esdc_install_password<cn_install_esdc>`
      -
    * - :ref:`remote_node<cn_install_esdc>`
      - default: ``true`` if ``cfgdb_admin_ip`` is outside the admin subnet; otherwise ``false``

    * - :ref:`admin_email<cn_install_operator>`
      -

    * - :ref:`skip_final_summary<cn_install_confirm>`
      - default: ``false``
    * - :ref:`skip_final_confirm<cn_install_confirm>`
      - default: ``false``
    * - :ref:`auto_reboot<cn_install_confirm>`
      - default: ``false`` (wait for USB stick removal confirm)
