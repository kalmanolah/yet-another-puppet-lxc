#############################
# Manages LXC network stuff #
#############################
class lxc::network {
  # file { '/etc/resolvconf/resolv.conf.d/head':
  #   content => template('lxc/resolvconf.erb'),
  #   owner   => 'root',
  #   group   => 'root',
  #   mode    => '0644',
  #   require => Package['resolvconf'],
  # }

  # Optionally configure firewall
  if $lxc::configure_firewall {
    firewall {
      '010 accept all to lxc interface':
        proto       => 'all',
        iniface     => $::lxc::bridge,
        action      => 'accept';

      # Needs more NAT
      '011 snat for lxc containers':
        chain       => 'POSTROUTING',
        jump        => 'MASQUERADE',
        proto       => 'all',
        source      => '10.0.3.0/24',
        destination => '! 10.0.3.0/24',
        table       => 'nat';
    }
  }
}
