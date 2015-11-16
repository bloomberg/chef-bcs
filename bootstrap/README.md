## Bootstrapping a Ceph cluster

The bootstrapping process is broken into three directories:
bare_metal_scripts
This directory contains a few helper scripts that are purpose built for bare servers (not VMs). Most, if not all, have the same name as the scripts found in vagrant_scripts but with the internals different except for function names.
common_scripts
This directory contains a number of scripts and helper functions that are common to both bare metal and vagrant.
vm_scripts
This directory contains three VM specific directories (vagrant_scripts, vbox_scripts and vmware_scripts). The net result of a VM based Ceph Cluster is what is produced through these different VM methodologies. The point is to show you how to use whatever method you would like.
vagrant_scripts
This directory contains vagrant/virtualbox specific built environments. Vagrant is often used to aid in speeding the process up since it has pre-built "box" (virtualbox) environments which they host. The under lying VMs are just virtualbox (assuming default virtualbox provider) but some of the basics are already "pre-baked".
The main script in this directory is the BOOT_GO.sh which can be ran like ./BOOT_GO.sh or with parameters ./BOOT_GO.sh -b etc. The -b option allows you to just build the VMs only so that you can clone them if you wish. Just remember, if you do clone them then the IPs and MAC addresses will be the same which means you can't run the normal VMs and the cloned VMs at the same time unless you alter the MAC address and IPs of the clones.
vbox_scripts
This directory bypasses the vagrant process and uses raw ISOs of your desired Ceph operating system. This process will take a little longer on the VM build portion and require a download of a default ISO image such as on of these:
CentOS 7.1
RHEL 7.1 (this requires your own licensed version so no download link provided)
Ubuntu 14.04...
Just download or copy the ISO into the /iso directory in this vbox_scripts directory
This process is closest related to the bare metal server cluster bootstrapping!
vmware_scripts
Some people don't have VirtualBox installed or don't want to install VirtualBox because they use VMware Fusion. So, this process helps you use vmware as part of your workflow.
