Alerting Configuration
**********************

Upon initial configuration of the monitoring system, it is advised to configure alerting (or escalation rules) based on specific needs of your organization or environment.

.. note:: By default, monitored servers will send alerts only if they are members of the *Notification* host group. If alerts from newly created servers should be sent automatically, it is necessary to configure the auto assignment of the *Notification* host group in :ref:`virtual data center monitoring settings <dc_monitoring_settings>` (``Datacenter -> Settings -> MON_ZABBIX_HOSTGROUPS_VM``).


Notification Delivery Configuration
###################################

Individual notifications are sent to users or group of users. These have to be preconfigured in Zabbix configuration `Administration -> Users <https://www.zabbix.com/documentation/3.0/manual/config/users_and_usergroups/user>`_. It is possible to configure different media for every user or group of users through which the notification shall be delivered. This is configurable in `Administration -> Media types <https://www.zabbix.com/documentation/3.0/manual/web_interface/frontend_sections/administration/mediatypes>`_. *Danube Cloud* comes preconfigured with following media types:

* **Email** media type sends notifications via email. Emails are delivered via local mail server on the monitoring server. The destination email address can be configured in user's media type settings (Send to).

* **SMS** media type sends SMS notifications via an SMS provider. Notifications are sent over HTTP to the SMS gateway. This media type requires :ref:`sms.sh and hqsms.py <advanced_monitoring_media>` scripts. The phone number has to be able to receive text messages and it can be configured in user's media type settings (Send to).

* **Ludolph** media type sends notifications via the `Ludolph Jabber bot <https://github.com/erigones/Ludolph>`_. It requires the :ref:`ludolph.sh <advanced_monitoring_media>` script. XMMP receiver address needs to be configured in user's media type settings (Send to).

* **Prowl** media type sends notifications over PUSH notifications to Apple IOS devices. It requires the :ref:`prowl.sh and prowl.pl <advanced_monitoring_media>` scripts. The API user key needs to be configured in user's media type settings (Send to).

* **NMA** media type sends notifications over PUSH notifications to Google Android devices. It requires the :ref:`nma.sh and nma.pl <advanced_monitoring_media>`. The API user key needs to be configured in user's media type settings (Send to).


Actions and Escalations
#######################

The notification sending has to be set in the `Configuration -> Actions <https://www.zabbix.com/documentation/3.0/manual/config/notifications/action>`_ section. Erigones recommends using and modifying the following actions:

* **Notify (with recovery message)** - preconfigured notification action that sends notifications for every host in the **Notification** host group.
* **Notify - Custom Alerts (without recovery message)** - preconfigured notification action that sends notifications for every trigger related to items in the *Custom Alerts* application. Used internally by the *Danube Cloud* system (e.g. backup failure).

For correct notification delivery, it is necessary to configure users in the *Operations* section of preconfigured actions.

It is also possible to configure `escalations <https://www.zabbix.com/documentation/3.0/manual/config/notifications/action/escalations>`_ for sending notifications according to reaction times or alert acknowledgments.


.. _advanced_monitoring_media:

Advanced notification delivery configuration
############################################

Scripts used for the correct functioning of following media types need to be placed in the ``/etc/zabbix/alertscripts`` folder on the monitoring server.


SMS
```

* **sms.sh**

    .. code-block:: bash

        #!/bin/bash

        PHONE="${1}" # Set this in user media
        shift
        # Everything else is the message itself
        MSG=$(echo "${@}" | sed 's/|\?\*UNKNOWN\*|\?//g')

        /etc/zabbix/alertscripts/hqsms.py "${PHONE}" "${MSG}"

* **hqsms.py** - python script, which requires the `requests <http://docs.python-requests.org/en/latest/>`_ Python library. The library can be installed via ``yum install python-requests`` or ``pip install requests``.

    .. code-block:: python

        #!/usr/bin/env python

        import sys
        import requests

        __USERNAME__ = 'SMS API user name'
        __PASSWORD__ = '123456672aaaa6b508858551264' # md5 hash of the password
        __FROM__ = 'Sender name'

        def login_data():
            return { 'username': __USERNAME__, 'password': __PASSWORD__, 'from': __FROM__}

        def sms_send(phone, message):
            data = login_data()
            data['to'] = phone.replace('+', '')
            data['message'] = message
            return requests.post("https://ssl.hqsms.com/sms.do", data)


        if __name__ == '__main__':
            if len(sys.argv) < 3:
                sys.stderr.write('Usage: %s <phone> <message>\n' % sys.argv[0])
                sys.exit(1)

            msg = str(' '.join(sys.argv[2:]))
            r = sms_send(sys.argv[1], msg[:160])

            print('%s (%s)' % (r.text, r.status_code))

            if r.status_code == 200 and r.text.startswith('OK:'):
                sys.exit(0)

            sys.exit(1)


Ludolph
```````

* **ludolph.sh** - requires the `Ludolph <https://github.com/erigones/Ludolph>`_ running directly on the monitoring server. Ludolph needs to have the web server module turned on.

    .. code-block:: bash

        #!/bin/bash

        JID=${1}
        shift
        MSG=$(echo "${@}" | sed 's/|\?\*UNKNOWN\*|\?//g')

        curl -s -m 3 -o /dev/null -d "jid=${JID}&msg=${MSG}" http://127.0.0.1:8922/alert


Prowl
`````

* **prowl.sh**

    .. code-block:: bash

        #!/bin/bash

        APP="Danube Cloud"
        APIKEY="${1}" # Set this in user media
        shift
        # Everything else is the message itself
        MSG=$(echo "${@}" | cut -d ':' -f 2- | sed 's/|\?\*UNKNOWN\*|\?//g')
        # The message begins with the "${HOSTNAME}:"
        HOST=$(echo "${@}" | cut -d ':' -f 1)
        # Extract priority from the message end, which is in format "(${TRIGGER.NSEVERITY})"
        # Subtract 3, because prowl uses priorities from -2 (Very Low) to 2 (Emergency)
        # (We are not using the 0 / "Not classified" severity in zabbix)
        PRIO=$((${MSG:(-2):1} - 3))

        /etc/zabbix/alertscripts/prowl.pl -apikey="${APIKEY}" -application="${APP}" \
            -priority="${PRIO}" -event="${HOST}" -notification="${MSG}"

* **prowl.pl** - can be downloaded from https://www.prowlapp.com/static/prowl.pl


NMA
```

* **nma.sh**

    .. code-block:: bash

        #!/bin/bash

        APP="Danube Cloud"
        APIKEY="${1}" # Set this in user media
        shift
        # Everything else is the message itself
        MSG=$(echo "${@}" | cut -d ':' -f 2- | sed 's/|\?\*UNKNOWN\*|\?//g')
        # The message begins with the "${HOSTNAME}:"
        HOST=$(echo "${@}" | cut -d ':' -f 1)
        # Extract priority from the message end, which is in format "(${TRIGGER.NSEVERITY})"
        # Subtract 3, because prowl uses priorities from -2 (Very Low) to 2 (Emergency)
        # (We are not using the 0 / "Not classified" severity in zabbix)
        PRIO=$((${MSG:(-2):1} - 3))

        /etc/zabbix/alertscripts/nma.pl -apikey="${APIKEY}" -application="${APP}" \
            -priority="${PRIO}" -event="${HOST}" -notification="${MSG}"

* **nma.pl** - can be downloaded from https://www.notifymyandroid.com/files/nma.pl


.. note:: Zabbix is a registered trademark of `Zabbix LLC <http://www.zabbix.com>`_.
