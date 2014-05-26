##################################
# Defined type for LXC Container #
##################################
define lxc::container (
  $template,
  $ensure         = $lxc::params::container_ensure,
  $vgname         = $lxc::params::container_vgname,
  $fstype         = $lxc::params::container_fstype,
  $fssize         = $lxc::params::container_fssize,
  $mem_limit      = $lxc::params::container_mem_limit,
  $mem_soft_limit = $lxc::params::container_mem_soft_limit,
  $memsw_limit    = $lxc::params::container_memsw_limit,
  $cpus           = $lxc::params::container_cpus,
  $cpu_shares     = $lxc::params::container_cpu_shares,
  $backingstore   = $lxc::params::container_backingstore,
  $autostart      = $lxc::params::container_autostart,
  $group          = $lxc::params::container_group,
) {
  require lxc
  include lxc::params

  Exec { path => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/'] }


  #######################
  # Container autostart #
  #######################

  $autostart_value = $autostart ? {
    true  => '1',
    false => '0',
  }

  $group_ensure = $group ? {
    undef   => 'absent',
    default => 'present',
  }


  ##############################
  # Determine creation command #
  ##############################

  $create_cmd_base = "lxc-create -n ${name} -t ${template}"
  $create_cmd_extra = $backingstore ? {
    'lvm'   => " -B lvm --vgname=${vgname} --fstype=${fstype} --fssize=${fssize}",
    'loop'  => ' -B loop',
    'btrfs' => ' -B btrfs',
    default => '',
  }
  $create_cmd = "${create_cmd_base}${create_cmd_extra}"


  #################################################
  # Set up a flow, since we don't like duplicates #
  #################################################

  exec { "Create_${template}_container_${name}_with_storage_${backingstore}":
    command => $create_cmd,
    unless  => "test -f ${lxc::params::container_dir}/${name}/config",
    onlyif  => "test ${ensure} != absent",
  }
  ->
  exec { "Stop_container_${name}":
    command => "lxc-stop -n ${name}",
    onlyif  => [
      "lxc-info -n ${name} | grep -Ei '^state:\s+RUNNING$'",
      "test ${ensure} = absent -o ${ensure} = stopped",
    ],
  }
  ->
  exec { "Start_container_${name}":
    command => "lxc-start -d -n ${name}",
    onlyif  => [
      "lxc-info -n ${name} | grep -Ei '^state:\s+STOPPED$'",
      "test ${ensure} = running -o ${ensure} = present",
    ],
  }
  ->
  exec { "Set_mem_limit_container_${name}":
    command => "lxc-cgroup -n ${name} memory.limit_in_bytes ${mem_limit}",
    onlyif  => [
      "lxc-info -n ${name} | grep -Ei '^state:\s+RUNNING$'",
      "test ${mem_limit} != undef",
      "test `lxc-cgroup -n ${name} memory.limit_in_bytes` != ${mem_limit}",
    ],
  }
  ->
  exec { "Set_mem_soft_limit_container_${name}":
    command => "lxc-cgroup -n ${name} memory.soft_limit_in_bytes ${mem_soft_limit}",
    onlyif  => [
      "lxc-info -n ${name} | grep -Ei '^state:\s+RUNNING$'",
      "test ${mem_soft_limit} != undef",
      "test `lxc-cgroup -n ${name} memory.soft_limit_in_bytes` != ${mem_soft_limit}",
    ],
  }
  ->
  exec { "Set_memsw_limit_container_${name}":
    command => "lxc-cgroup -n ${name} memory.memsw.limit_in_bytes ${memsw_limit}",
    onlyif  => [
      "lxc-info -n ${name} | grep -Ei '^state:\s+RUNNING$'",
      "test ${memsw_limit} != undef",
      "test `lxc-cgroup -n ${name} memory.memsw.limit_in_bytes` != ${memsw_limit}",
    ],
  }
  ->
  exec { "Set_cpus_container_${name}":
    command => "lxc-cgroup -n ${name} cpuset.cpus ${cpus}",
    onlyif  => [
      "lxc-info -n ${name} | grep -Ei '^state:\s+RUNNING$'",
      "test ${cpus} != undef",
      "test `lxc-cgroup -n ${name} cpuset.cpus` != ${cpus}",
    ],
  }
  ->
  exec { "Set_cpu_shares_container_${name}":
    command => "lxc-cgroup -n ${name} cpu.shares ${cpu_shares}",
    onlyif  => [
      "lxc-info -n ${name} | grep -Ei '^state:\s+RUNNING$'",
      "test ${cpu_shares} != undef",
      "test `lxc-cgroup -n ${name} cpu.shares` != ${cpu_shares}",
    ],
  }
  ->
  exec { "Destroy_container_${name}":
    command => "lxc-destroy -n ${name}",
    onlyif  => [
      "test -f ${lxc::params::container_dir}/${name}/config",
      "test ${ensure} = absent",
    ],
  }

  # If the container is present, set some values
  if $ensure != 'absent' {
    file_line { "Set_container_${name}_autostart":
      path   => "${lxc::params::container_dir}/${name}/config",
      match  => '^lxc.start.auto = (1|0)$',
      line   => "lxc.start.auto = ${autostart_value}",
      before => Exec["Start_container_${name}"],
    }

    file_line { "Set_container_${name}_group":
      ensure => $group_ensure,
      path   => "${lxc::params::container_dir}/${name}/config",
      match  => '^lxc.group = .*$',
      line   => "lxc.group = ${group}",
      before => Exec["Start_container_${name}"],
    }
  }
}
