# -*- mode: ruby -*-
# vi: set ft=ruby :

######### Provisioning Variables #################

# Apache 
server_name="local.dev.com"
server_alias="dev" 

# MySql
db_name="devdb"
db_user="devuser"
db_pass="devuser"

# Set a local private network IP address.
# See http://en.wikipedia.org/wiki/Private_network for explanation
# You can use the following IP ranges:
#   10.0.0.1    - 10.255.255.254
#   172.16.0.1  - 172.31.255.254
#   192.168.0.1 - 192.168.255.254
server_ip             = "192.168.33.66"
server_cpus           = "1"   # Cores
server_memory         = "1024" # MB

# UTC        for Universal Coordinated Time
# EST        for Eastern Standard Time
# CET        for Central European Time
# US/Central for American Central
# US/Eastern for American Eastern
server_timezone  = "US/Eastern"

##################################################

Vagrant.configure(2) do |config|
  
  #config.vm.box = "ubuntu/trusty64"
  config.vm.box = "ubuntu/xenial64"
  
  config.vm.network "private_network", ip: server_ip
  config.vm.host_name = server_name
  
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder ".", "/vagrant", mount_options:["dmode=777","fmode=666"]

  config.vm.network "forwarded_port", guest: 3306, host: 3306
  
  config.vm.provider "virtualbox" do |vb|
    vb.name = server_name
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false

    # Set server cpus
    vb.customize ["modifyvm", :id, "--cpus", server_cpus]

    # Set server memory
    vb.customize ["modifyvm", :id, "--memory", server_memory]

    # Set the timesync threshold to 10 seconds, instead of the default 20 minutes.
    # If the clock gets more than 15 minutes out of sync (due to your laptop going
    # to sleep for instance, then some 3rd party services will reject requests.
    vb.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]

  end

  config.vm.provision "shell" , path:"provision.sh", args: [server_name, server_alias, db_name, db_user, db_pass]
  
end
