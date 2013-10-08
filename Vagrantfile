Vagrant::Config.run do | config |
    config.vm.box = "precise64"
    config.vm.forward_port 80, 3000

    config.vm.customize ["modifyvm", :id, "--memory", 1024]

    config.vm.provision :puppet, :options => "--verbose"
end

