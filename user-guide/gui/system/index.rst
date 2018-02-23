.. _system:

System
******

The System menu is available only to :ref:`SuperAdmin <roles>` users and offers information and functionality related to the *Danube Cloud* system itself.

.. note:: The System menu is available only in Danube Cloud version 3.0 or newer.

=============================== ================
:ref:`Access Permissions <acl>`
------------------------------- ----------------
*SuperAdmin*                    read-write
=============================== ================

.. contents:: Table of Contents

----

Overview
########

Statistics about :ref:`virtual data centers<dcs>`, :ref:`compute nodes<nodes>` and :ref:`virtual servers<vms>`.

.. image:: img/system-stats.png

----

Configuration
#############

*Danube Cloud* system is configured via :ref:`virtual data center settings<dc_settings>`. 

----

.. _system_maintenance:

Maintenance
###########

System Update
=============

The system maintenance view can be used for updating the *Danube Cloud* software on the :ref:`mgmt01 virtual server<admin_dc>` and compute nodes. Please refer to the :ref:`maintenance section of this user guide<update_esdc>` for more information on updating *Danube Cloud*.

The main *Danube Cloud* components should be updated in the following order:
   1. The software on the :ref:`management server<admin_dc>` must be updated first (via :ref:`GUI<system_maintenance>` or :ref:`API<update_dc_mgmt>`).
   2. Then, the software on all compute nodes should be updated to the same version as on the management server (via :ref:`GUI<system_maintenance>` or :ref:`API<update_dc_node>`).
   3. An optional update of the platform image should be performed last (by :ref:`running a script<update_platform>` on the compute node).

.. note:: Please, always read the release notes before performing an update: https://github.com/erigones/esdc-ce/wiki/Release-Notes

.. note:: The update functionality is not bound to a specific virtual data center, which means that the update tasks are logged into the :ref:`task log<tasklog>` of the *main* virtual data center. You are advised to switch to the *main* virtual data center before performing an update.

.. seealso:: Some features may require a new version of the :ref:`Platform Image<update_platform>`.

.. image:: img/system-update.png

----
