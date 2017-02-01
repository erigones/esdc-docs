.. _acl:

Access Control Lists (ACL)
**************************

*Danube Cloud* supports the creation of :ref:`user groups <groups>` with different :ref:`permissions <permissions>` and :ref:`users <users>` assigned to them. Groups can be assigned to :ref:`virtual data centers <dcs>`.

A :ref:`virtual data center <datacenters>` is accessible to a :ref:`user <users>` only if at least one of the following conditions is met:

    * The user is a *SuperAdmin* (see :ref:`roles <roles>` below).
    * The data center is a public one (has the *Access* attribute set to *Public*).
    * The user is the owner of the virtual data center (see :ref:`roles <roles>` below).
    * The user is part of a user group, which is attached to the virtual data center.

.. seealso:: For more information about managing user, please have a look at the :ref:`user management chapter <users>` in the virtual data center section.

.. seealso:: For more information about managing user groups, please have a look at the :ref:`user group management chapter <groups>` in the virtual data center section.


.. _roles:

Roles
#####

* **User** - Can do basic operations with virtual servers that are owned by the user and update her/his profile.
* **DCAdmin** - A :ref:`virtual data center <dcs>` administrator has complete access to all virtual servers in a virtual data center.
* **SuperAdmin** - Has full control over the whole *Danube Cloud* system.
* **VmOwner** - Owner of the virtual machine.


.. _permissions:

Permissions
###########

A Permission represents an authorization for using a certain feature of the *Danube Cloud* system. A Permission can be assigned to a :ref:`user group <groups>` by a *SuperAdmin*.

* **Admin** - A *DCAdmin* is equivalent to a *DC owner*.
* **NetworkAdmin** - Authorization to manage :ref:`networks <networks>` in a virtual data center. *DCAdmin* role is required.
* **ImageAdmin** - Authorization to manage :ref:`disk images <images>` in a virtual data center. *DCAdmin* role is required.
* **ImageImportAdmin** - Authorization to import :ref:`disk images <images>` into a virtual data center. *DCAdmin* and *ImageAdmin* roles are required.
* **TemplateAdmin** - Authorization to manage :ref:`templates <templates>` in a virtual data center. *DCAdmin* role is required.
* **IsoAdmin** -  Authorization to manage :ref:`ISO images <iso_images>` in a virtual data center. *DCAdmin* role is required.
* **UserAdmin** - Authorization to manage :ref:`users <users>` in a virtual data center. *DCAdmin* role is required.
* **DnsAdmin** - Authorization to manage :ref:`DNS records <dns>` in a virtual data center. *DCAdmin* role is required.

