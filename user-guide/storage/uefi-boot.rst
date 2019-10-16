.. _uefi_boot:

UEFI Boot 
*********

Danube Cloud ``v4.2`` and later supports hybrid boot from USB and from a disk. That means you can boot the legacy BIOS way or UEFI way without any modifications. Just change your boot settings in BIOS.

If you are installing a new compute node using ``v4.2`` or higher, you don't have to do anything. By upgrading a platform from previous versions using ``esdc-platform-upgrade``, USB boot will automatically receive UEFI support. However platform upgrade of disk install will not create EFI partitions because it would require destroying the zones pool.

Disk UEFI Boot And Replacing Disks
==================================

UEFI boot requires at least one EFI partition. Installer creates EFI partitions on every disk in zones pool. This ensures that you will be able to boot from disk (when disk install is selected) even after disk(s) failure/replacement. Furthermore, ``esdc-platform-upgrade`` always checks the EFI partitions and reinstalls them as needed (even if the platform is not neccesary).

If you replace any disk, the appropriate EFI partitions will be reinstalled on next run of ``esdc-platform-upgrade``.

If you want to reinstall EFI partitions without platform upgrade, just run ``esdc-platform-upgrade`` with the current platform version, e.g. ``esdc-platform-upgrade $(uname -v|sed 's/esdc_//')``.

