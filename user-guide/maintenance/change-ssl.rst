.. _change_ssl:


Changing SSL Certificate
########################

For changing the SSL certificate of the *Danube Cloud* web management services you will need a file containing your certificate, intermediate certificates and associated private keys in PEM format concatenated together.

.. code-block:: bash

    user@laptop:~ $ es login -username admin -password $PW

    user@laptop:~ $ es set /system/settings/ssl-certificate -cert file::mycert.pem

.. warning:: The SSL certificate change will affect both the :ref:`API <API>` and :ref:`GUI <GUI>` endpoints on the management server.
