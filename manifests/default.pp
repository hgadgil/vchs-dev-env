$as_vagrant   = 'sudo -u vagrant -H bash -l -c'
$home         = '/home/vagrant'

Exec {
  path => ['/usr/sbin', '/usr/bin', '/sbin', '/bin']
}

package { 'curl':            ensure => 'latest' }
package { 'build-essential': ensure => 'latest' }
package { 'git-core':        ensure => 'latest' }

exec { 'apt-get-update': command => "apt-get update -y" }

exec { 'install_rvm':
  command => "${as_vagrant} 'curl -L https://get.rvm.io | bash -s stable'",
  creates => "${home}/.rvm",
  require => Package['curl']
}

exec { 'install_ruby':
  command => "${as_vagrant} '${home}/.rvm/bin/rvm install 1.9.3-p392 && rvm alias create default ruby-1.9.3-p392'",
  creates => "${home}/.rvm/bin/ruby",
  require => Exec['install_rvm']
}

package { 'bundler': ensure => 'installed', provider => 'gem' }

file { "${home}/vchs": ensure => 'directory' }
