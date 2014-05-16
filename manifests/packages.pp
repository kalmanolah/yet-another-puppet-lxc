##############################
# Installs required packages #
##############################
class lxc::packages {
  package { 'lxc':
    ensure => 'present',
  }
}
