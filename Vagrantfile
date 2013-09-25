Vagrant::Config.run do | config |
    config.vm.box = "lucid64"
    config.vm.box_url = "http://files.vagrantup.com/lucid64.box"
    
    config.vm.forward_port 80, 3000

    config.vm.provision :puppet, :options => "--verbose"
end

