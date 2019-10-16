.. _log_files:


List of Log File Locations
**************************

Management
##########

Logs from GUI, API, automated tasks (e.g. periodic backups) and from the version upgrade process can be found inside *mgmt01.local* VM. You can login there using ssh without a password (only) from the first compute node (first ssh to the first compute node and then ssh as root to the IP address of GUI).

Main log directory: **/opt/erigones/log/**

Most important logfiles: **mgmt.log** and **main.log**

If you encounter an error in GUI/API (e.g. error 500), go to these logfiles and search for an traceback or othes sort of error message.

There are also other log files with minor importance, such as access logs, auth logs, task log (logging all tasks issuet for compute nodes and version upgrade logs.

If you want to see classic logs from the VMs operating system itself, see **/var/log/**.


Node
#####

Install logs
============

During the installation before the first reboot, all actions are logged into **/var/log/prompt-config.log** on a node. After the first reboot, the next script depend on whether it is the first compute node (`esdc-ce-hn-*`) or you are adding a new node to existing DC installation (`esdc-ce-cn-*`).

    A) The first compute node install logfile: **/var/log/headnode-install.log**

    B) All next compute nodes install logfile: **/var/log/computenode-install.log**


Runtime logs
============

All other *Danube Cloud* logs are located in **/opt/erigones/log/**.

Look into these if you encounter unavailable node or other misbehaving actions that involve a compute node. It is recommended to look into **fast.log** first because `erigonesd:fast` daemon is doing the most work. You can find there also **update\*** logs from the node version upgrade process. Please note that main upgrade logs are in the *mgmt01.local* VM.

If you want to see classic logs from the VMs operating system itself, see **/var/adm/**, **/var/log/** and **svcs -L** for system services.
