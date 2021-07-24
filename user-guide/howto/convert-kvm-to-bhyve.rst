.. _kvm_to_bhyve:

How to convert KVM to Bhyve hypervisor
**************************************

After introduction of *Bhyve* hypervisor in *SmartOS*, the frequently asked question is how to easily convert the old virtual server running on *KVM* hypervisor to *Bhyve*.

In *Danube Cloud* there is an easy way how to do it: 

**Create a snapshot or backup and restore it into new virtual machine.**

.. note:: The new virtual server can be created on the same node or on different one because *Danube Cloud* can restore snapshots and backups to any node in the cluster.

Example conversion using a snapshot
###################################

#. (Optional) Adjust virtual server for bhyve.

	#. Networking - unlike *KVM*, *Bhyve* does not use DHCP for configuring guest network. Set either static IP or configure `cloud-init` to update the IP address after each boot (using *SmartOS* datasource).

	#. Console - *Bhyve* supports VNC console only for UEFI boot. It is always useful to setup *serial console* access before conversion. You can take inspiration in `this ansible role <https://github.com/erigones/esdc-factory/blob/master/ansible/roles/serial-getty/tasks/main.yml>`_. The console can be accessed using ``vmadm console <vm_uuid>``.


#. :ref:`Create snapshot <snapshot-actions>` of the virtual server running on *KVM*. You need to create snapshot for all disks the virtual server has. :guilabel:`Servers -> (virtual server) -> Snapshots -> Create snapshot`. If you use `qemu guest agent`, you don't need to stop the server to get a consistent clone.

    .. image:: ../gui/servers/img/vm_create_snapshot.png


#. :ref:`Create a new virtual server <vm-add>` in parallel to the existing one (:guilabel:`Servers -> Add Server`, click :guilabel:`Show advanced settings -> Hypervisor Type` during the server creation and **select Bhyve**).

	The destination disk(s) *must* have the same size as the source disk(s).

	Don't select any OS image for disk as it will be deleted anyway.

    .. image:: ../gui/servers/img/vm_change_settings.png


#. Go back to source virtual server's snapshot list and restore the snapshot(s) to the respective disk(s). :guilabel:`Servers -> (virtual server) -> Snapshots`, click :guilabel:`Manage` button near the snapshot name, then click :guilabel:`To other server...` and select the destination server and disk.

	.. image:: img/vm_snapshots_list.png

	.. image:: ../gui/servers/img/vm_manage_snapshot.png

	.. image:: img/vm_snap_restore_to_other_server.png


#. (Optional) Stop the source server to avoid IP conflict and start the new server. If you've set a different IP, you don't need to stop the source server.


#. (Optional) Delete the old *KVM* server.

.. note:: It is recommended to do a last backup of the old server before deletion (:guilabel:`Backups` tab next to :guilabel:`Snapshots`). Server backups are not deleted when you delete a server and you can find them in :guilabel:`Nodes -> (node name) -> Backups`.

