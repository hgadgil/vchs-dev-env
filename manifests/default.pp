# Run from vagrant vm as:
# /opt/vagrant_ruby/bin/ruby /opt/vagrant_ruby/bin/puppet apply \
#    --verbose /tmp/vagrant-puppet/manifests/default.pp \
#    --detailed-exitcodes 

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

package { 'curl':                ensure => 'installed' }
package { 'build-essential':     ensure => 'installed' }
package { 'git-core':            ensure => 'installed' }
package { 'libcurl4-gnutls-dev': ensure => 'installed' }
package { 'libmysqlclient-dev':  ensure => 'installed' }
package { 'libaio1':             ensure => 'installed' }

exec { 'apt-get-update': command => "apt-get update -y" }

# --- Install rvm and ruby via rvm, bundler

exec { 'install_rvm':
  command => "${as_vagrant} 'curl -L https://get.rvm.io | bash -s stable'",
  creates => "${home}/.rvm",
  require => Package['curl']
}

exec { 'install_ruby':
  command => "${as_vagrant} '${home}/.rvm/bin/rvm install ${ruby_version} && rvm alias create default ruby-${ruby_version}'",
  creates => "${home}/.rvm/bin/ruby",
  require => Exec['install_rvm']
}

package { 'bundler': ensure => 'installed', provider => 'gem' }

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
    Exec["install_ruby"],
    File["${vchs_base}"], 
    Exec["copy scripts"],
    Exec["copy configs"],
  ]
}

# --- Clone base repositories

exec { 'install vcap-services-base':
    creates   => "${vchs_base}/vcap-services-base",
    command   => "git clone https://github.com/vchs/vcap-services-base.git ${vchs_base}/vcap-services-base",
    user => "vagrant",
    logoutput => true,
    require => Notify["base_setup"]
}

exec { 'update vcap-services-base':
    cwd => "${vchs_base}/vcap-services-base",
    command   => "git pull origin master && bundle",
    user => "vagrant",
    logoutput => true,
    require => Exec['install vcap-services-base']
}

exec { 'install cf-services-release':
    creates   => "${vchs_base}/cf-services-release",
    command   => "git clone https://github.com/vchs/cf-services-release.git ${vchs_base}/cf-services-release",
    user => "vagrant",
    logoutput => true,
    require => Notify["base_setup"]
}

exec { 'update cf-services-release':
    cwd => "${vchs_base}/cf-services-release",
    command   => "git pull origin master && git submodule update --init --recursive",
    user => "vagrant",
    logoutput => true,
    require => Exec['install cf-services-release']
}

exec { 'update mysql_service':
    cwd => "${vchs_base}/cf-services-release/src/mysql_service",
    command   => "bundle",
    user => "vagrant",
    logoutput => true,
    require => Exec['update cf-services-release']
}

exec { 'install nats':
    creates   => "${vchs_base}/nats",
    command   => "git clone https://github.com/cloudfoundry/nats.git ${vchs_base}/nats",
    user => "vagrant",
    logoutput => true,
    require => Notify["base_setup"]
}

exec { 'update nats':
    cwd => "${vchs_base}/nats",
    command   => "git pull origin master && bundle",
    user => "vagrant",
    logoutput => true,
    require => Exec['install nats']
}

#exec { 'install service_controller':
#    creates   => "${vchs_base}/service_controller",
#    command   => "git clone https://github.com/vchs/service_controller.git ${vchs_base}/service_controller",
#    user => "vagrant",
#    logoutput => true,
#    require => Notify["base_setup"]
#}

#exec { 'update service_controller':
#    cwd => "${vchs_base}/service_controller",
#    command   => "git pull origin master",  # TODO: Add bundle
#    user => "vagrant",
#    logoutput => true,
#    require => Exec['install service_controller']
#}

notify { "cloned_base_repos":
  require => [
    Exec['update vcap-services-base'],
    Exec['update cf-services-release'],
    Exec['update nats'],
    Exec['update mysql_service'],
#    Exec['update service_controller'],
  ]
}

# --- Setup external dependencies

exec { 'setup dependencies as root':
    cwd => "${vcap}/scripts",
    command   => "/bin/bash setup_mysql_ldconf_file.sh",    
    logoutput => true,
    require => Notify["cloned_base_repos"]
}

exec { 'setup external dependencies':
    cwd => "${vcap}/scripts",
    command   => "${as_vagrant} 'setup_mysql.sh'",
    user => "vagrant",
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
