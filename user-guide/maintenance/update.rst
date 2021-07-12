.. _update_esdc:

Updating Danube Cloud
*********************

.. contents:: Table of Contents

Updating Danube Cloud Software
##############################

The *Danube Cloud* software can be updated via the :ref:`system maintenance GUI view <system_maintenance>` or the :ref:`API<API>`. This section describes updating of *Danube Cloud* by using *es* command line tool, which is used to perform API calls.

Starting with *Danube Cloud* 3.0 the update functionality was completely reimplemented and a maintenance GUI view was added. Before version 3.0, the update feature was considered experimental and updating was usually performed :ref:`manually<update_manual>`.

The main *Danube Cloud* components should be updated in the following order:
   1. The software on the :ref:`management server<admin_dc>` must be updated first (via :ref:`GUI<system_maintenance>` or :ref:`API<update_dc_mgmt>`).
   2. Then, the software on all compute nodes should be updated to the same version as on the management server (via :ref:`GUI<system_maintenance>` or :ref:`API<update_dc_node>`).
   3. An optional update of the platform image should be performed last (by :ref:`running a script<update_platform>` on the compute node).

.. note:: Please, always read the release notes before performing an update: https://github.com/erigones/esdc-ce/wiki/Release-Notes

.. note:: The update functionality is not bound to a specific virtual data center, which means that the update tasks are logged into the :ref:`task log<tasklog>` of the *main* virtual data center.

.. seealso:: Some features may require a new version of the :ref:`Platform Image<update_platform>`.

In the examples below the parameters have following meaning:

* ``<version>`` - version of the *Danube Cloud* software to which system should be updated. This can be either a git tag or SHA1 of a git commit. A version tag is prefixed with a ``v`` character (e.g, ``v4.0-rc1``). All available version tags are visible here: https://github.com/erigones/esdc-ce/tags
* ``update.key`` - X509 private key file in PEM format used for authentication against EE git server.
* ``update.crt`` - X509 private cert file in PEM format used for authentication against EE git server.


.. _update_dc_mgmt:

Updating Danube Cloud Software on Management Server
===================================================

When updating *Danube Cloud*, the management server must be updated first.

.. note:: ``file::`` prefix must be used when passing files to ``-key``/``-cert`` parameters, otherwise the *es* command will not parse them correctly.

.. note:: You can set API_KEY variable in the *es* tool, so you don't have to use login command. For more info see: https://docs.danube.cloud/api-reference/es.html

.. code-block:: bash

    user@laptop:~ $ es login -username admin -password $PW
    user@laptop:~ $ es get /system/version
    user@laptop:~ $ es set /system/update -version <version> -key file::/full/path/to/update.key -cert file::/full/path/to/update.crt
    user@laptop:~ $ es get /system/version


.. _update_dc_node:

Updating Danube Cloud Software on Compute Nodes
===============================================

For a compute node one additional parameter needs to be provided:

* ``<hostname>`` - name or UUID of the compute node which you are updating.

.. code-block:: bash

    user@laptop:~ $ es login -username admin -password $PW
    user@laptop:~ $ es get /system/node/<hostname>/version

    user@laptop:~ $ es set /node/(hostname)/define -status 1  # First set the node to maintenance state
    user@laptop:~ $ es set /system/node/<hostname>/update -version (version) -key file::/full/path/to/update.crt -cert file::/full/path/to/update.crt
    user@laptop:~ $ es set /node/<hostname>/define -status 2  # Set the node back to online state

    user@laptop:~ $ es get /system/node/<hostname>/version


.. _update_manual:

Updating Danube Cloud Software Manually
=======================================

In case something goes wrong with the software update it is always possible to manually update *Danube Cloud* on the :ref:`mgmt01 server<admin_dc>` or compute nodes.
The update procedure is essentially the same as performed from the GUI or API. In both cases, the ``esdc-git-update`` [1]_ script is run on the mgmt01 virtual server or compute node and if successful, the *Danube Cloud* services should be restarted. It requires one parameter - ``<version>``, which is the version of the *Danube Cloud* software. This can be either a git tag or SHA1 of a git commit. A version tag is prefixed with a ``v`` character (e.g, ``v4.0-rc1``). All available version tags are visible here: https://github.com/erigones/esdc-ce/tags


.. note:: When updating *Danube Cloud*, the software on the :ref:`management server<admin_dc>` must be updated first and then the procedure should be repeated on all compute nodes.

.. note:: Please, always read the release notes before performing an update: https://github.com/erigones/esdc-ce/wiki/Release-Notes

.. note:: Please make sure that users have only read access to *Danube Cloud* during manual update.


* First, log in as root to the mgmt01 server (should be update first) or compute node:

    .. code-block:: bash

        user@laptop:~ $ ssh root@node01
        [root@node01 ~] ssh root@<ip-of-mgmt01>  # available from the first compute node

* Examine the current *Danube Cloud* version:

    .. code-block:: bash

        [root@mgmt-or-node ~] cd /opt/erigones
        [root@mgmt-or-node erigones] cat core/version.py

            __version__ = '4.0'
            __edition__ = 'ce'

        [root@mgmt-or-node erigones] git status

            # HEAD detached at v4.0
            nothing to commit, working directory clean

* Run the ``esdc-git-update`` [1]_ upgrade script:

    .. code-block:: bash

        [root@mgmt-or-node erigones] bin/esdc-git-update <version>

            ...
            You should now restart all Danube Cloud system services
            (bin/esdc-service-control restart)


    .. [1] The ``bin/esdc-git-update`` does the following:

        - Downloads (``git fetch``) and switches the repository (``git checkout <version>``) to the requested version;
        - Updates other internal software components by running:

            - on mgmt01 server: ``bin/esdc-appliance-update``
            - on compute node: ``bin/esdc-node-update``

        - Runs a post-deploy script:

            - on mgmt01 server: ``bin/ctl.sh deploy --update``
            - on compute node: ``bin/ctl.sh deploy --update --node``

* If everything goes well, restart the *Danube Cloud* system services:

    .. code-block:: bash

        [root@mgmt-or-node erigones] bin/esdc-service-control restart



.. _update_platform:

Updating Platform Image on Compute Nodes
########################################

A Platform Image contains a modified version of the *SmartOS* hypervisor. Each version of *Danube Cloud* is tested and released with a specific version of the Platform Image. The Platform Image is usually upgraded with each major release of *Danube Cloud* or when there is some security issue in the kernel.

.. note:: Please, always read the release notes before performing an update: https://github.com/erigones/esdc-ce/wiki/Release-Notes

The platform update should be carried out manually by running the ``esdc-platform-upgrade`` script on a compute node. It requires one parameter - the *Danube Cloud* ``<version>``, which is the same as the `git tag version identifier for the Danube Cloud software <https://github.com/erigones/esdc-ce/tags>`__.

Depending on the node installation type, the script does one of the following:

    * *USB-booted* compute node: downloads a compute node USB image and overwrites the contents of the existing USB image with it.
    * *HDD-booted* compute node: finds out the target platform version according to the provided *Danube Cloud* version; downloads a platform image; creates and activates a new boot environment.

A successful platform update should be followed by a reboot of the compute node.

.. code-block:: bash

    user@laptop:~ $ ssh root@node01

    [root@node01 ~] /opt/erigones/bin/esdc-platform-upgrade v4.0

        ...
        *** Upgrade completed successfully ***

     [root@node01 ~] init 6  # reboot

