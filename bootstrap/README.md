## Bootstrapping a Ceph cluster

The bootstrapping process is broken into three directories:

**/bare_metal**

This directory contains a few helper scripts that are purpose built for bare servers (not VMs). Most, if not all, have the same name as the scripts found in vagrant_scripts but with the internals different except for function names.

**/common**

This directory contains a number of scripts and helper functions that are common to both bare metal and vagrant.

**/vms**

This directory contains an additional directory called:

**/vms/vagrant**

If you want to simply build a test cluster on your Linux or Mac then go to the <chef-bcs root>/bootstrap/vms/vagrant directory and issue the following command:

**./VAGRANT_UP**

This bash script will gather everything that is needed and call 'vagrant up' to build a centos-7.x (default OS) version of a Ceph cluster with the latest version of Ceph.

See the README.md file in the same directory as VAGRANT_UP for additional information and possible issue resolution.
