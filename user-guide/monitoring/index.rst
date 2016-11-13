.. _monitoring:

==========
Monitoring
==========

For monitoring and alerting purposes, *Danube Cloud* uses the Zabbix monitoring system. The *Danube Cloud* environment differentiates between two types of monitoring servers:

* :ref:`Central monitoring server (internal) <main_monitoring>`.

    The central monitoring server handles:

    * Monitoring and alerting of compute node hardware (server).
    * Monitoring and alerting of compute node software (ErigonOS).
    * Agentless monitoring of virtual servers (monitoring from the compute node perspective).
    * Optional agent-based monitoring and alerting of virtual servers.

* :ref:`Virtual data center monitoring server (external) <dc_monitoring>`.

    The data center monitoring servers are used for agent-based monitoring and alerting of virtual servers.


.. toctree::
   :maxdepth: 1

   main_monitoring
   dc_monitoring
   vm_monitoring
   alerting


.. note:: Zabbix is a registered trademark of `Zabbix LLC <http://www.zabbix.com>`_.
