.. _dc_dns:
.. _dns:

DNS
###

The DNS feature included in *Danube Cloud* enables a simple management of DNS domains and records.

.. image:: img/domain_management.png

=============================== ================
:ref:`Access Permissions <acl>`
------------------------------- ----------------
*SuperAdmin*                    read-write
*DCAdmin*                       read-only
*DnsAdmin*                      read-write on DNS records (DC-bound domains only)
=============================== ================

.. note:: In the upper right corner is a button labeled :guilabel:`Show All`, which can be used to display all domains, including domains that are not associated with the current working virtual data center.


Recursion
=========

DNS service has recursion enabled for all network subnets that are defined within :ref:`networks list <dc_network>` in *Danube Cloud* installation. All other (=external) IP addresses will receive only authoritative responses (domain must be present locally in the domain list).


DNS Domain Parameters
=====================

* **Name** - DNS domain name.
* **Access** - DNS domain visibility. One of:

    * *Public* - DNS domain is usable by all users in this virtual data center.
    * *Private* - DNS domain is usable by *SuperAdmins*, *DCAdmins*, and owners of this domain.
* **Type** - PowerDNS domain type which determines how records are replicated. One of:

    * *MASTER* - PowerDNS will use DNS protocol messages to communicate changes with slaves.
    * *NATIVE* - PowerDNS will use database replication between master DNS server and slave DNS servers.
* **Owner** - DNS domain owner.
* **DC-bound?** - Whether a DNS domain is bound to a specific virtual data center.
* **Records** - Number of DNS records within a DNS domain and a link to DNS record management (read-only).
* **TSIG Key(s)** - Comma separated list of TSIG keys that will be allowed to do zone transfer query for this domain.
* **Description**

Managing a DNS Domain
=====================

A DNS domain can be created, updated and deleted only by a *SuperAdmin*.

.. image:: img/domain_update.png

.. note:: The default DNS domain (:ref:`VMS_VM_DOMAIN_DEFAULT <dc_dns_settings>`) cannot be deleted.


Attaching a DNS Domain
======================

Used for associating an existing domain with a virtual data center. Can be performed only by a *SuperAdmin*.

.. note:: A DNS domain can be only used when attached to a virtual data center.


Detaching a DNS Domain
======================

Used for removing an association of a domain with a virtual data center. Can be performed only by a *SuperAdmin*.


DNS Records
===========

.. image:: img/domain_records.png


DNS Record Parameters
=====================

* **Name** - The name of the DNS record - the full URI the DNS server should pick up on.
* **Type** - DNS record type. One of: *A*, *AAAA*, *CERT*, *CNAME*, *HINFO*, *KEY*, *LOC*, *MX*, *NAPTR*, *NS*, *PTR*, *RP*, *SOA*, *SPF*, *SSHFP*, *SRV*, *TLSA*, *TXT*.
* **Content** - DNS record content - the answer to the DNS query.
* **TTL** - How long (seconds) the DNS client is allowed to remember this record.
* **Enabled** - If set to false, this record is hidden from DNS clients.
* **Changed** - The date and time when the record was last changed (read-only).


Managing DNS Records
====================

Custom DNS records can be created, updated or removed by a *SuperAdmin* or by a *DnsAdmin* (DC-bound domain only).


External Zone Transfers
=======================

Danube Cloud DNS service allows zone transfers to external DNS slaves using TSIG keys. TSIG keys can be specified separately for each domain configuration (:guilabel:`Datacenter -> DNS -> Edit domain`).

.. note:: Notifications of zone changes are sent only to servers that are specified in NS record for given domain.

Format of TSIG keys is following:

    .. code-block:: bash

		key_algorithm:key_name:secret,key_algorithm:second_key_name:secret,...

It is comma separated list of keys where each key consists of three parts:

* **key_algorithm** - Can be one of: *hmac-md5, hmac-sha1, hmac-sha224, hmac-sha256, hmac-sha384, hmac-sha512*.
* **key_name** - Main key identifier.
* **secret** - The shared secret.

Example of generating a TSIG trasfer key:

    .. code-block:: bash

        [root@dns-slave ~] apt install bind9-utils      # "bind" package on redhat-like systems
        [root@dns-slave ~] dnssec-keygen -a HMAC-SHA256 -b 256 -r /dev/urandom -n HOST mykeyname.example.com
        Kmykeyname.example.com.+157+48197
        [root@dns-slave ~] grep ^Key: Kmykeyname.example.com.+157+48197.private
        Key: wI6XiocuMR8X/DySzKVbp2SdzZZeXCsQLjEs6HRlnkY=

The final TSIG key is:

    .. code-block:: bash

		hmac-sha256:mykeyname.example.com:wI6XiocuMR8X/DySzKVbp2SdzZZeXCsQLjEs6HRlnkY=

You can add it into domain settings in Danube Cloud and configure it in DNS slave server.
Example confguration for BIND server:

    .. code-block:: bash

		key "mykeyname.example.com" {
			algorithm hmac-sha256;
			secret "iuSO1JFqF2fhNmgfSJHn0tsudtiW2odyYixOBpc/yuA=";
		};

		server 50.100.150.200 {
			keys { mykeyname.example.com; };
		};

		zone "example.com" {
			type slave;
			file "slave/example.com.zone";
			masters {
				50.100.150.200;  // ns01.example.com
			};
			allow-transfer { };
			notify no;
		};

Verify zone transfer using *dig* command:

    .. code-block:: bash

		dig axfr -y "hmac-sha256:mykeyname.example.com:wI6XiocuMR8X/DySzKVbp2SdzZZeXCsQLjEs6HRlnkY=" example.com @50.100.150.200

