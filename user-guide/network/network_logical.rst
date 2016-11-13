.. _network_logical:

Logical Networks
****************

A Logical Network represents a model of network configuration, which allows *Danube Cloud* to define virtual network interfaces, IP addresses and domains for virtual machines.

Logical networks are defined by the following attributes:

- IP address range
- default gateway
- VLAN ID (0 for untagged VLAN)
- NIC tag
- DNS resolvers
- reverse domain

Logical networks are mapped onto physical network interfaces through :ref:`NIC tags <network_nictag>`. NIC tags map the logical network and compute node's physical network interfaces. Virtual network interfaces are created on top of NIC tags.

*Danube Cloud* comes with the following preconfigured logical networks:

- **admin** - Required for internal use of *Danube Cloud* and data center management.
- **lan** - Dummy network example for virtual machines.

.. warning:: The malfunctioning of the **admin** network can cause operational problems of certain *Danube Cloud* parts and seriously affect **the correct functioning** of your data center. Therefore, any work or configuration regarding this network should be approached with great care! This network should be exclusively used for *Danube Cloud* internal purposes and not for use with virtual or physical servers outside of *Danube Cloud*.

.. seealso:: Detailed explanation on how to work with logical networks, can be found in the :ref:`Virtual data center -> Networks <networks>` section.
