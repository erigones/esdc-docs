.. _metadata:

Virtual Server Metadata
***********************

The metadata of a :ref:`virtual server <vm>` can be used to send arbitrary information from the *Danube Cloud* :ref:`GUI <gui>` or :ref:`API <api>` into the guest operating system. Bidirectional communication between the :ref:`hypervisor <erigonos>` and the virtual server is provided through an emulated serial link. The metadata is stored as key=value string pairs (32 max), where keys can 128 characters long and values 65536 characters long.

.. seealso:: Metadata of a virtual server can be modified via the :ref:`virtual server's setting page in the GUI <vm-manage>`.


Common Virtual Server Metadata
##############################

*Danube Cloud* uses following virtual server metadata for post-configuration of virtual servers installed from its images:

* **root_authorized_keys** - List of public SSH keys separated by newlines (``\n``) that are automatically added to a virtual server from the virtual server's owner profile.
* **cloud-init:user-data** - `Cloud-init <https://cloudinit.readthedocs.io>`__ configuration directive used to change the root password for KVM virtual servers.
* **user-script** - A post-configuration script used to update the root's authorized_keys on SunOS zones.

.. warning:: Following virtual server metadata is reserved by *Danube Cloud*:

    * resize_needed


Managing Virtual Server Metadata via the API
############################################

.. code-block:: bash

    user@mylaptop:~ es login -username admin -password $PW

    user@mylaptop:~ es set /vm/vm01.erigones.com/define \
        -mdata parameter1:value1,parameter2:value2,parameter3:value3

    user@mylaptop:~ es set /vm/vm01.erigones.com


Retrieving and Manipulating Metadata on a Running Virtual Server
################################################################

mdata-client
------------

The *mdata-list*, *mdata-get*, *mdata-put* and *mdata-delete* command line programs are used to read, update and delete metadata within a virtual server. These tools are part of the `mdata-client <https://github.com/joyent/mdata-client>`__ package.

* `mdata-client RPM for RHEL/CentOS <https://github.com/erigones/mdata-client-rpm>`__
* `mdata-client package for Ubuntu <https://launchpad.net/ubuntu/+source/joyent-mdata-client>`__
* :download:`current version of mdata-get.exe for Microsoft Windows <files/mdata-get.exe>`


Reading Metadata on a Running Virtual Server
--------------------------------------------

.. code-block:: bash

    [root@myserver ~] mdata-list
    parameter1
    parameter3
    parameter2

    [root@myserver ~] mdata-get parameter1
    value1


Updating Metadata on a Running Virtual Server
---------------------------------------------

.. warning:: Users inside a virtual server may at any time modify the metadata, which may affect applications that use these metadata.

.. code-block:: bash

    [root@myserver ~] mdata-put parameter4 value4

    [root@myserver ~] mdata-delete parameter3

    user@mylaptop:~ es set /vm/vm01.erigones.com -force  # Update VM configuration to see the changed metadata in Danube Cloud

