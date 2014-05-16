#####################
# Initial LXC class #
#####################
class lxc (
  $bridge             = $lxc::params::bridge,
  $domain             = $lxc::params::domain,
  $configure_firewall = $lxc::params::configure_firewall,
) inherits lxc::params {
  include lxc::packages
  include lxc::network
  include lxc::services

  # Basic folders
  file {
    '/usr/share/lxc':
      ensure => directory;

    '/etc/lxc':
      ensure => directory;

    '/etc/lxc/auto':
      ensure  => directory,
      recurse => true,
      purge   => true,
      require => File['/etc/lxc'];

    '/var/lib/lxc':
      ensure => directory;
  }

  # We need cgroups
  # mount { '/sys/fs/cgroup':
  #   device   => 'cgroup',
  #   fstype   => 'cgroup',
  #   options  => 'defaults,blkio,net_cls,freezer,devices,cpuacct,cpu,cpuset,memory,clone_children',
  #   atboot   => true,
  # }
}
