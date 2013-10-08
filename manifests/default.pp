$as_vagrant   = 'sudo -u vagrant -H bash -l -c'
$home         = '/home/vagrant'
$vchs_base    = "${home}/vchs"
$vcap         = "${home}/vcap"

$ruby_version = "1.9.3-p392"

Exec {
  path => ['/usr/sbin', '/usr/bin', '/sbin', '/bin', './',
           "${home}/.rvm/gems/ruby-${ruby_version}@global/bin",
           "${home}/.rvm/bin",
  ]
}

exec { 'install base packages': 
  cwd => "${vcap}/setup",
  command   => "/bin/bash install_base_packages.sh",    
  logoutput => true, }

notify { "install base ubuntu libs":
  require => [
    Exec["install base packages"],
  ]
}

# --- Install rvm and ruby via rvm, bundler

exec { 'install_rvm':
  command => "${as_vagrant} 'curl -L https://get.rvm.io | bash -s stable'",
  creates => "${home}/.rvm",
  require => Notify['install base ubuntu libs'],
  timeout => 900,
    }

exec { 'install_ruby':
  command => "${as_vagrant} '${home}/.rvm/bin/rvm install ${ruby_version} && rvm alias create default ruby-${ruby_version}'",
  creates => "${home}/.rvm/bin/ruby",
  require => Exec['install_rvm'],
  timeout => 900,
}

package { 'bundler': 
  ensure => 'installed', 
  provider => 'gem',
  require => Exec["install_ruby"]
}

# --- Create Base folders & copy necessary configs/scripts

file { "${vchs_base}": 
  ensure => 'directory',
  owner => "vagrant",
  group => "vagrant"
}

file { "${vcap}": 
  ensure => 'directory',
  owner => "vagrant",
  group => "vagrant"
}

file { "${vcap}/download": 
  ensure => 'directory',
  owner => "vagrant",
  group => "vagrant"
}

exec { "copy setup scripts":
  cwd => "${vcap}",
  user => vagrant,
  command => "rm -rf setup && cp -r /vagrant/setup .",
  require => File["${vcap}"]
}

exec { "copy scripts":
  cwd => "${vcap}",
  user => vagrant,
  command => "rm -rf scripts && cp -r /vagrant/scripts .",
  require => File["${vcap}"]
}

exec { "copy configs":
  cwd => "${vcap}",
  user => vagrant,
  command => "rm -rf config && cp -r /vagrant/config .",
  require => File["${vcap}"]
}

notify { "base_setup":
  require => [
    Package["bundler"],
    File["${vchs_base}"], 
    Exec["copy scripts"],
    Exec["copy configs"],
    Exec["copy setup scripts"],
  ]
}

# --- Clone base repositories

exec { 'install vcap-services-base':
    creates   => "${vchs_base}/vcap-services-base",
    command   => "git clone https://github.com/vchs/vcap-services-base.git ${vchs_base}/vcap-services-base",
    user => "vagrant",
    logoutput => true,
    timeout => 900,
    require => Notify["base_setup"]
}

exec { 'update vcap-services-base':
    cwd => "${vchs_base}/vcap-services-base",
    command   => "git pull origin master && bundle",
    user => "vagrant",
    timeout => 900,
    logoutput => true,
    require => Exec['install vcap-services-base']
}

exec { 'install cf-services-release':
    creates   => "${vchs_base}/cf-services-release",
    command   => "git clone https://github.com/vchs/cf-services-release.git ${vchs_base}/cf-services-release",
    user => "vagrant",
    timeout => 900,
    logoutput => true,
    require => Notify["base_setup"]
}

exec { 'update cf-services-release':
    cwd => "${vchs_base}/cf-services-release",
    command   => "git pull origin master && git submodule update --init --recursive",
    user => "vagrant",
    timeout => 900,
    logoutput => true,
    require => Exec['install cf-services-release']
}

exec { 'update mysql_service':
    cwd => "${vchs_base}/cf-services-release/src/mysql_service",
    command   => "bundle",
    user => "vagrant",
    timeout => 900,
    logoutput => true,
    require => Exec['update cf-services-release']
}

exec { 'install cf-services-contrib-release':
    creates   => "${vchs_base}/cf-services-contrib-release",
    command   => "git clone https://github.com/cloudfoundry/cf-services-contrib-release.git ${vchs_base}/cf-services-contrib-release",
    user => "vagrant",
    timeout => 900,
    logoutput => true,
    require => Notify["base_setup"]
}

exec { 'update cf-services-contrib-release':
    cwd => "${vchs_base}/cf-services-contrib-release/src/services/echo",
    command   => "git pull origin master && bundle",
    user => "vagrant",
    timeout => 900,
    logoutput => true,
    require => Exec['install cf-services-contrib-release']
}

#exec { 'install service_controller':
#    creates   => "${vchs_base}/service_controller",
#    command   => "git clone https://github.com/vchs/service_controller.git ${vchs_base}/service_controller",
#    user => "vagrant",
#    timeout => 900,
#    logoutput => true,
#    require => Notify["base_setup"]
#}

#exec { 'update service_controller':
#    cwd => "${vchs_base}/service_controller",
#    command   => "git pull origin master",  # TODO: Add bundle
#    user => "vagrant",
#    timeout => 900,
#    logoutput => true,
#    require => Exec['install service_controller']
#}

notify { "cloned_base_repos":
  require => [
    Exec['update vcap-services-base'],
    Exec['update cf-services-release'],
    Exec['update mysql_service'],
    Exec['update cf-services-contrib-release'],
#    Exec['update service_controller'],
  ]
}

# --- Setup external dependencies

exec { 'setup dependencies as root':
    cwd => "${vcap}/setup",
    command   => "/bin/bash setup_mysql_ldconf_file.sh",    
    logoutput => true,
    require => Notify["cloned_base_repos"]
}

exec { 'setup external dependencies':
    cwd => "${vcap}/setup",
    command   => "${as_vagrant} 'setup_mysql.sh'",
    user => "vagrant",
    timeout => 900,
    logoutput => true,
    require => Notify["cloned_base_repos"]
}

notify { "setup dependencies":
  require => [
    Exec['setup external dependencies'],
    Exec['setup dependencies as root'],
  ]
}

# --- Start various components

exec { 'start components':
    cwd => "${vcap}/scripts",
    command   => "${as_vagrant} 'components.sh start'",
    user => "vagrant",
    logoutput => true,
    require => Notify["setup dependencies"]
}
