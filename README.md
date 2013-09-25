Starting a Vagrant VM for dev/test:
==================================

Prerequisites:
-------------
1. Install Virtualbox
2. Install Virtualbox additions
3. Install vagrant (http://www.vagrantup.com)

Starting Vagrant VM:
-------------------

1. Clone this repo
    ``git clone https://...``ß

2. Run:
    ``vagrant up``

3. The vagrant VM is unstable when it comes to network connection so some libs don't get
    installed on first go. If this is the case, run:
    ``vagrant halt && vagrant up``

4. To log on to the vagrant VM:
    ``vagrant ssh``

Installation Folder Structure:
-----------------------------

    /home/vagrant
    |
    \
     - vcap (scripts, config files and runtime - logs, pidfiles, db etc...)
       |
       \
        - config
        - scripts
        - log
        - store
        - packages
     - vchs (Contains cloned repositories)
       |
       \
        - cf-services-release
        - vcap-services-base
        - ...

Known Issues:
------------

1. Vagrant VM does not start on first try. In this case, redo the setup, i.e.
   vagrant halt && vagrant up

2. NATS process takes up 40% - 60% CPU. So you'll notice some slowness when running shell
   commands.
   - There is a handy script $HOME/vcap/scripts/components.sh to start/stop all components
   - Individual components (X) can be started/stopped via X_ctl.sh
