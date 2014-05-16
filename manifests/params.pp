######################
# Default parameters #
######################
class lxc::params {
  $bridge                   = 'lxcbr0'
  $domain                   = 'lxc'
  $configure_firewall       = false

  $container_dir            = '/var/lib/lxc'
  $container_ensure         = 'running'
  $container_vgname         = 'vg0'
  $container_fssize         = '1G'
  $container_fstype         = 'ext4'
  $container_autostart      = true

  # $container_mem_limit      = '1024M'
  # $container_memsw_limit    = '2048M'
  # $container_mem_soft_limit = '512M'
  # $container_cpus           = range('0', $::processorcount)
  # $container_cpu_shares     = '1024'
  $container_mem_limit      = undef
  $container_memsw_limit    = undef
  $container_mem_soft_limit = undef
  $container_cpus           = undef
  $container_cpu_shares     = undef
}
