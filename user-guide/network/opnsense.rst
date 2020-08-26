.. _opnsense:

Integrated OPNSense appliance
*****************************

From `v4.3` there is an option during installation to deploy `OPNSense <https://opnsense.org/>`_ VM to serve as a router between **admin** network and **external** network. It is configured automatically at install but no further configuration changes (and upgrades) are performed from *Danube Cloud* as there's no OPNSense API integration so far.

What is configured during install:

- It acts as a default gateway for **admin** network.
- Outgoing NAT is configured on the **external** (uplink) interface.
- Forwards for *Danube Cloud* services are present from external interface, namely:
- **Danube GUI/API**: *<opnsense external IP>:443* (classic HTTPS port, TCP).
- **DNS**: *<opnsense external IP>:53* (classic DNS port, TCP/UDP).
- **OPNSense default web GUI** is moved from port *443* to port **444** (and it's accessible from the internet by default!).
- Root password is set the same as the root password on the compute node (ssh login).
- Root authorized keys from underlying compute node are pushed to OPNSense VM so there's no password required when logging from the compute node using ssh (same as the other admin VMs).
- Root e-mail is set the same as the administrator password during *Danube Cloud* install.
- OPNSense API keys are generated and stored in VM metadata for future use.

.. note:: The OPNSense appliance is currently not upgraded with *Danube Cloud* upgrades. Please upgrade it separately.

