Importing Virtual Servers from Other Platforms
***********************************************

Before the actual import procedure, the destination :ref:`virtual server <vms>` must be created and deployed in *Danube Cloud*.

.. note:: When creating a destination virtual server disk, it is recommended to temporarily turn on the *ZLE* compression algorithm (in order to free unallocated space) or permanently turn on *LZ4* compression.


Importing Virtual Server from Linux KVM
#######################################

* Obtaining necessary information about virtual disks of the source virtual machine.

    .. code-block:: bash

        root@kvm-host-02:/storage/local/# ls -lah 
            total 139G
            drwxr-xr-x 2 root root 4.0K Aug  3 05:12 .
            drwxr-xr-x 3 root root 4.0K Aug  3 05:12 ..
            -rw-r--r-- 1 root root 301G Nov  7 19:51 vm-100-disk-1.qcow2

        root@kvm-host-02:/storage/local/# qemu-img info vm-100-disk-1.qcow2 
            image: vm-100-disk-1.qcow2
            file format: qcow2
            virtual size: 300G (322122547200 bytes)
            disk size: 139G
            cluster_size: 65536

* (Optional) For example, the NFS file system can be used in order to speed up the import procedure of virtual servers. The network file system enables to directly read data from the source server and write data to the target compute node. The transfer speed is affected by the speed of the network and IO performance of the source and target physical disk drives.

    .. code-block:: bash

            [root@node01 ~] mount -F nfs -o vers=3,proto=tcp,retrans=3,timeo=10 \
                172.17.0.13:/storage/local/ /nfs


* Determining the destination VM's UUID.

    .. code-block:: bash

        [root@node01 ~] vmadm list | grep demo.lan
            185da3d2-d7ed-467e-bbf5-f5ec7b8ce21c KVM 512 stopped demo.lan

* Running the actual import process.

    .. code-block:: bash

        [root@node01 ~] /opt/erigones/bin/qemu-img convert -p -f qcow2 \
            -O host_device /nfs/vm-100-disk-1.qcow2 \
            /dev/zvol/rdsk/zones/185da3d2-d7ed-467e-bbf5-f5ec7b8ce21c-disk0

    .. warning:: Before starting the import process, the source and destination virtual machines must be turned off!

    .. note:: The ``-p`` parameter displays the progress bar.


Importing Virtual Servers with MS Windows Server OS from VMware
###############################################################

.. note:: All preparatory tasks need to be performed on the VMware platform.

* Uninstall **VMware tools** from the running virtual machine.

* Download the latest **VIRTIO** drivers for Windows (https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso).

* Install the **VIRTIO** drivers through the command line: ``pnputil -i -a D:\WIN8\AMD64\*.INF``.

* Turn off the virtual machine and copy the disk images onto the target compute node.

* Running the actual import process.

    .. code-block:: bash

        [root@node01 ~] /opt/erigones/bin/qemu-img convert -p -f vmdk \
            -O host_device /zone/migration/demo.vmdk \
            /dev/zvol/rdsk/zones/185da3d2-d7ed-467e-bbf5-f5ec7b8ce21c-disk0

    .. warning:: Before starting the import process, the source and destination virtual machines must be turned off!

    .. note:: The ``-p`` parameter displays the progress bar.
