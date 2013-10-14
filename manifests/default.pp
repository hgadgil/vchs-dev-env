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

# --- Create Base folders & copy necessary configs/scripts & setup ssh keys

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

exec { "copy ssh keys":
  cwd => "${vcap}",
  creates => "${home}/.ssh/id_rsa.pub",
  user => vagrant,
  command => "cp /vagrant/ssh_keys/id_rsa* ${home}/.ssh",
  require => File["${vcap}"]
}

exec { "copy ssh config":
  cwd => "${vcap}",
  creates => "${home}/.ssh/config",
  user => vagrant,
  command => "cp /vagrant/ssh_config ${home}/.ssh/config",
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

notify { "copy files":
  require => [
    File["${vchs_base}"], 
    Exec["copy scripts"],
    Exec["copy configs"],
    Exec["copy setup scripts"],
    Exec["copy ssh keys"],
    Exec["copy ssh config"],
  ]
}

exec { 'setup base ssh_keys':
  cwd => "${vcap}/setup",
  command   => "/bin/bash setup_ssh_keys.sh",
  logoutput => true,
  require => Notify["copy files"],
}

exec { 'install base packages':
  cwd => "${vcap}/setup",
  command   => "/bin/bash install_base_packages.sh",
  logoutput => true,
  require => Exec["setup base ssh_keys"],
}

notify { "base installation":
  require => [
    Exec["install base packages"],
  ]
}

# --- Install rvm and ruby via rvm, bundler

exec { 'install_rvm':
  command => "${as_vagrant} 'curl -L https://get.rvm.io | bash -s stable'",
  creates => "${home}/.rvm",
  require => Notify['base installation'],
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

notify { "ruby and dependencies":
  require => Package["bundler"],
}
# --- Clone base repositories

exec { 'install vcap-services-base':
    creates   => "${vchs_base}/vcap-services-base",
    command   => "git clone https://github.com/vchs/vcap-services-base.git ${vchs_base}/vcap-services-base",
    user => "vagrant",
    logoutput => true,
    timeout => 900,
    require => Notify["ruby and dependencies"]
}

exec { 'update vcap-services-base':
    cwd => "${vchs_base}/vcap-services-base",
    command   => "git pull origin master && bundle",
    user => "vagrant",
    timeout => 900,
    logoutput => true,
    require => Exec['install vcap-services-base']
}

#exec { 'install cf-services-release':
#    creates   => "${vchs_base}/cf-services-release",
#    command   => "git clone https://github.com/vchs/cf-services-release.git ${vchs_base}/cf-services-release",
#    user => "vagrant",
#    timeout => 900,
#    logoutput => true,
#    require => Notify["ruby and dependencies"]
#}

#exec { 'update cf-services-release':
#    cwd => "${vchs_base}/cf-services-release",
#    command   => "git pull origin master && git submodule update --init --recursive",
#    user => "vagrant",
#    timeout => 900,
#    logoutput => true,
#    require => Exec['install cf-services-release']
#}

#exec { 'update mysql_service':
#    cwd => "${vchs_base}/cf-services-release/src/mysql_service",
#    command   => "bundle",
#    user => "vagrant",
#    timeout => 900,
#    logoutput => true,
#    require => Exec['update cf-services-release']
#}

exec { 'clone update private repos':
    cwd => "${vcap}/setup",
    command   => "${as_vagrant} 'clone_update_private_repos.sh'",
    user => "vagrant",
    timeout => 900,
    logoutput => true,
    require => Notify["ruby and dependencies"]
}

notify { "cloned_base_repos":
  require => [
    Exec['update vcap-services-base'],
#    Exec['update cf-services-release'],
#    Exec['update mysql_service'],
    Exec['clone update private repos'],
  ]
}

# --- Setup external dependencies

#exec { 'setup dependencies as root':
#    cwd => "${vcap}/setup",
#    command   => "/bin/bash setup_mysql_ldconf_file.sh",
#    logoutput => true,
#    require => Notify["cloned_base_repos"]
#}

#exec { 'setup external dependencies':
#    cwd => "${vcap}/setup",
#    command   => "${as_vagrant} 'setup_mysql.sh'",
#    user => "vagrant",
#    timeout => 900,
#    logoutput => true,
#    require => Notify["cloned_base_repos"]
#}

notify { "setup dependencies":
  require => [
     Notify["cloned_base_repos"],
#    Exec['setup external dependencies'],
#    Exec['setup dependencies as root'],
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
