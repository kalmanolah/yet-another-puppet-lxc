#############################
# Manages LXC network stuff #
#############################
class lxc::network {
  file_line { 'Set_lxc_dnsmasq_conf_file':
    path   => '/etc/default/lxc-net',
    match  => '^#*LXC_DHCP_CONFILE=.*$',
    line   => 'LXC_DHCP_CONFILE=/etc/lxc/dnsmasq.conf',
  }

  file { '/etc/lxc/dnsmasq.conf':
    content => template('lxc/conf/lxc_dnsmasq.conf'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  concat { '/etc/lxc/dnsmasq.hosts':
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  concat::fragment { 'lxc_dnsmasq_initial_hosts':
    target  => '/etc/lxc/dnsmasq.hosts',
    content => "10.0.3.1 ${::fqdn} ${::hostname}",
    order   => '01',
  }

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
