Vagrant.configure("2") do | config |
  config.vm.box = "precise64"
    
  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", 1024]
  end
                  
  config.vm.provision "puppet" do |p|
    p.options = "--verbose"
  end
end
