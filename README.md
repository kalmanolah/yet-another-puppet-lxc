puppet-lxc
==========

This is a Puppet module for managing LXC.
It should probably work on Ubuntu 14.04 LTS, and it might work on other distros (don't count on it).
Pull requests are very welcome.

The following cgroup container limits are supported:

- `memory.limit_in_bytes` (memory limit)
- `memory.soft_limit_in_bytes` (soft memory limit)
- `memory.memsw.limit_in_bytes` (memory + swap limit)
- `cpuset.cpus` (available cpus)
- `cpu.shares` (available cpu shares)

Usage
-----

Check out the manifests.

Contact
-------

Kalman Olah: [kal.mn](http://kal.mn).
