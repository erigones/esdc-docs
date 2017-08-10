.. _update_esdc:

Updating Danube Cloud
#####################

At the moment, *Danube Cloud* can be updated only using the :ref:`API<API>`. The **es** command line tool is used to perform API calls.

In the examples below the parameters have following meaning:

* ``(version)`` - version of the *Danube Cloud* software to which system should be updated. This can be either git tag or SHA1 of the git commit.

* ``update.key`` - X509 private key file in PEM format used for authentication against EE git server.

* ``update.crt`` - X509 private cert file in PEM format used for authentication against EE git server.

.. note:: If you are using Danube Cloud Enterprise Edition, you should have received the update.key/update.crt files with your :ref:`compute node license <node_license>`.
    In case you haven't received the update key and certificate please contact ``license@erigones.com``.

.. note:: If you are using Danube Cloud Community Edition, ``-key`` and ``-cert`` parameters can be omitted from the command line.


Updating Management Server
==========================

When updating *Danube Cloud*, the management server must be updated first.

.. note:: ``file::`` prefix must be used when passing files to ``-key``/``-cert`` parameters, otherwise the **es** command will not parse them correctly.

.. note:: You can set API_KEY variable in the ``es`` tool, so you don't have to use login command. For more info see: https://docs.danubecloud.org/api-reference/es.html

.. code-block:: bash

    user@laptop:~ $ es login -username admin -password $PW

    user@laptop:~ $ es set /system/update -version (version) -key file::/full/path/to/update.key -cert file::/full/path/to/update.crt

If - for some reason - your connection to the server gets interrupted during the update procedure, the update itself continues in the background. Just wait 5 to 15 minutes and check the system version by following ``es`` command:

.. code-block:: bash

    user@laptop:~ $ es get /system/version

If you see the new version number, the update has finished succesfully.
If you see the old version even after waiting some time, the upgrade has probably failed. You might try to re-run the update to see the error.


Updating Compute Nodes
======================

For a compute node one additional parameter needs to be provided:

* ``(hostname)`` - name of the node which you are updating.

.. code-block:: bash

    user@laptop:~ $ es login -username admin -password $PW

    user@laptop:~ $ es set /node/(hostname)/define -status 1  # First set the node to maintenance state
    user@laptop:~ $ es set /system/node/(hostname)/update -version (version) -key file::/full/path/to/update.crt -cert file::/full/path/to/update.crt
    user@laptop:~ $ es set /node/(hostname)/define -status 2  # Set the node's status back to online state
