.. _unattended_installation:

Unattended Compute Node Installation
************************************

.. note:: The unattended compute node installation is supported from *Danube Cloud* version 3.0.

The compute node installation can be automated by placing an ``answers.json`` file into the ``/private`` folder on the :ref:`newly created USB flash drive<usb_key_howto>`. The ``/private/answers.json`` should contain a flat JSON object with all the configuration values that should be automatically used as answers by the installer. If an answer is missing or invalid, the installer will stop at the question and wait for a valid answer.

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
        "skip_final_confirm": true
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

    * - :ref:`skip_final_confirm<cn_install_confirm>`
      - default: ``false``
