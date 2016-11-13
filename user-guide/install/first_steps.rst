.. _first_steps:

Post-installation Tasks
***********************

After you have successfully installed your first head node, you should log in into the central web management portal and configure at least some settings to customize your *Danube Cloud* installation to your needs:

- Update the ``admin's`` :ref:`user profile<user_profile>`: add your SSH public key and update other information.
    - To access profile settings for your current user click the *Profile* button at the top of the page.

- Adjust the compute node's :ref:`CPU, RAM <compute_node_settings>` and :ref:`node storage <node_storage_settings>` coefficients.
    - Go to *Nodes* item in the Main menu, select a node, then click on the node's hostname to change settings. Coefficients can be edited by clicking on the *Show advanced settings* button.

- Update :ref:`virtual data center settings <dc_settings>` for the *main* virtual data center.
    - Go to *Datacenter* in the Main menu and select *Settings* item in the *Datacenter* menu, to start editing settings.

- You may also want to :ref:`import some server images <images>` and :ref:`create some networks and IP addresses <networks>` before you create your first virtual server.
    - *Images* and *Networks* can be found under *Datacenter* item in the Main menu.

- Virtual servers should be logically grouped into virtual data centers so you should :ref:`create a virtual data center <dcs>` for each project, customer, etc.
    - Go to *Datacenter* -> *Datacenters* and start creating/managing virtual data centers.


You, the *Danube Cloud* administrator, should make yourself familiar with the :ref:`command-line client es <API>`, which can be used to perform some administrative tasks, e.g.:

- :ref:`Updating Danube Cloud <update_esdc>`.

- :ref:`Changing the SSL certificate <change_ssl>` for the *Danube Cloud* web management services.

