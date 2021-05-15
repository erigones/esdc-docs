.. _reset_admin_pass:

Reset Admin Password for GUI
****************************

1. Login to ``mgmt01.local`` using ssh

2. Issue password reset command

    .. code-block:: bash

        root@mgmt01:~# ctl.sh changepassword admin
        Changing password for user 'admin'
        Password:
        Password (again):
        Password changed successfully for user 'admin'

3. Login to GUI using the new password.
