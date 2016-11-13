.. _update_esdc:

Updating Danube Cloud
#####################

At the moment, Danube Cloud can be updated only using the :ref:`API<API>`. **es** command line tool is used to perform API calls.

In the examples below the parameters have following meaning:

* ``(version)`` - version of the Danube Cloud software to which system should be updated. This can be either git tag or SHA1 of the git commit.

* ``update.key`` - X509 private key file in PEM format used for authentication against EE git server.

* ``update.crt`` - X509 private cert file in PEM format used for authentication against EE git server.

.. note:: If you are using Danube Cloud Enterprise Edition, you should have received the update.key/update.crt files with your :ref:`compute node license <node_license>`.
    In case you haven't received the update key and certificate please contact ``license@erigones.com``.

.. note:: If you are using Danube Cloud Community Edition -key and -cert parameters can be omitted from the 


Updating Compute Nodes
======================

For compute node one additional parameter needs to be provided:

* ``(hostname)`` - name of the node which you are updating.

.. code-block:: bash

    user@laptop:~ es login -username admin -password $PW

    user@laptop:~ es set /system/node/(hostname)/update -version (version) -key update.crt -cert update.crt


Updating Management Server
==========================

.. code-block:: bash

    user@laptop:~ es login -username admin -password $PW

    user@laptop:~ es set /system/update -version (version) -key update.key -cert update.crt
