########################
# Manages LXC services #
########################
class lxc::services {
  service { 'lxc-net':
    ensure  => 'running',
    enable  => true,
  }

  service { 'lxc':
    ensure  => 'running',
    require => [Service['lxc-net']],
    enable  => true,
  }
}
