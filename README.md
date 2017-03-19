## Chef-BCS

[![Join the chat at https://gitter.im/bloomberg/chef-bcs](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/bloomberg/chef-bcs?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## DESCRIPTION

Installs and configures Ceph, a distributed network storage and filesystem designed to provide excellent performance, reliability, and scalability.

The current version is focused on installing and configuring Ceph for CentOS and RHEL.

## Prerequisites
1. Vagrant - https://www.vagrantup.com/downloads.html  (for development or just spinning up VM version of cluster - not needed for bare metal cluster)
2. VirtualBox - https://www.virtualbox.org/wiki/Downloads  
3. Git

## Instructions
1. Fork/clone repo
2. Navigate to `[whatever path]/ceph-bcs/bootstrap/vms/vagrant` directory
3. Launch Vagrant version to see how it works and to do development and testing by issuing **./CEPH_UP** command (in /bootstrap/vms/vagrant directory)

## Process (Vagrant)
Assuming you're in the path mentioned in #2 above.

To start a normal build simply do the following (no proxy):

>./CEPH_UP

NB: If you want to test the upstream `ceph-chef` cookbook then clone that repo, make your changes, copy your cloned repo into the `cookbooks` section of the is cloned repo and then run the following command to start the build and test:

>./CEPH_UP -d 0   <-- Run in debug mode

NB: Behind firewall:

>./CEPH_UP -p [whatever your http(s) proxy url]

>OR

>./CEPH_UP -d 0 -p [whatever your http(s) proxy url]  <-- Run in debug mode

### What happens...

1. Download CentOS 7.1 box version from Chef Bento upstream (7.2 and 7.3 versions of the bento/centos have sshd issues)
2. Download required cookbooks including ceph-chef which is the most important
3. Issue vagrant up that creates 4 VMs (dynamic and part of yaml file in /bootstrap/vms directory)
4. Spins down VMs and adds network adapters and interfaces, sets up folder sharing and start VMs again
5. Mounts shared folders (makes it easy to move cookbooks etc to VMs) and sets network and then setups up the bootstrap node ceph-bootstrap as a Chef Server
6. Sets up chef-client on all other VMs
7. Adds roles for specific Ceph types such as ceph-mon and ceph-osd etc for the given VM
8. Updates the environment json file (contains all of your override values of the defaults - different one for vagrant.json, staging.json and/or production.json) [Only vagrant.json is used in this repo. You will need to create the specific environment json file for your targeted environment]
9. Creates the Ceph Monitors first (ceph-mon role)
10. Creates the Ceph OSD nodes (ceph-osd role)
11. Creates the Ceph RGW node (ceph-radosgw role)
12. Creates the Ceph restapi node (ceph-restapi role)
13. Finishes the cluster simply by enabling the services

### Nodes (Vagrant) - Creates an S3 Ceph Object Store Example Cluster
These are the default names. You can can call them anything you want. The main thing is to keep them numbered and not named like a pet but instead, named like cattle :)

**ceph-bootstrap** - Bootstrap node that acts as the Chef Server, Repo Mirror (in some cases) and Cobbler Server

**ceph-vm1** - VM that has the ceph-mon, ceph-osd and ceph-radosgw roles applied

**ceph-vm2** - VM that has the ceph-mon and ceph-osd roles applied

**ceph-vm3** - VM that has the ceph-mon and ceph-osd roles applied

**NOTE:** ceph-bootstrap does NOT contain any ceph functionality

RADOS Gateway (RGW) uses **civetweb** as the embedded web server. You can login to any VM and issue a simple curl command (i.e., curl localhost or curl ceph-vm1.ceph.example.com or curl ceph-vm1). The hosts file is updated on all three VMs to support FQDN and short names.

### Login to VMs (Vagrant)
*Must* be located in the [wherever root dir]/bootstrap/vms/vagrant directory (vagrant keeps a .vagrant directory with node information in it)

***
Command(s):

**vagrant ssh ceph-bootstrap**

**vagrant ssh ceph-vm1**

**vagrant ssh ceph-vm2**

**vagrant ssh ceph-vm3**

NOTE: These names can be changed in the [wherever root dir]/bootstrap/vms/servers_config.yaml file.
***
**Sidebar:** Vagrant uses port forwarding on the first network adapter of a given VM it manages. It then uses ssh port on the localhost to make it simple on itself.

##### Helper Scripts (used in development to break tasks into smaller units of work)

**<wherever repo>/bootstrap/common**

**<wherever repo>/bootstrap/vms**

**<wherever repo>/bootstrap/vms/vagrant**

Note: The only one you must call is CEPH_UP which starts the whole process from creation of VMs to running Ceph cluster

For documentation on how to use this cookbook, refer to the **[USAGE](#usage)** section.

Note: The documentation is a WIP along with a few other features. This repo is actively managed.  

If there are **[issues](https://github.com/bloomberg/chef-bcs/issues)** then please go to the ISSUES section in this repo.

## REQUIREMENTS

### Chef

\>= 12.8+

### Platform

Tested as working:

* Ubuntu Trusty (16.04) [Still verifying updates work]
* CentOS (7.3)
* RHEL (7.3)

### Cookbooks

##### [IMPORTANT - Cookbook that everything else is based on]
##### https://github.com/ceph/ceph-chef

The ceph cookbook requires the following cookbooks from Chef:

https://supermarket.chef.io/

* [poise](https://supermarket.chef.io/cookbooks/poise)
* [poise-service](https://supermarket.chef.io/cookbooks/poise-service)
* [apt](https://supermarket.chef.io/cookbooks/apt)
* [apache2](https://supermarket.chef.io/cookbooks/apache2)
* [yum](https://supermarket.chef.io/cookbooks/yum)
* [ceph-chef](https://supermarket.chef.io/cookbooks/ceph-chef)
* [chef-client](https://supermarket.chef.io/cookbooks/chef-client)
* [chef-handler](https://supermarket.chef.io/cookbooks/chef-handler)
* [chef-sugar](https://supermarket.chef.io/cookbooks/chef-sugar)
* [collectd](https://supermarket.chef.io/cookbooks/collectd)
* [collectd_plugins](https://supermarket.chef.io/cookbooks/collectd_plugins)
* [cron](https://supermarket.chef.io/cookbooks/cron)
* [firewall](https://supermarket.chef.io/cookbooks/firewall)
* [logrotate](https://supermarket.chef.io/cookbooks/logrotate)
* [ntp](https://supermarket.chef.io/cookbooks/ntp)
* [sudo](https://supermarket.chef.io/cookbooks/sudo)
* [windows](https://supermarket.chef.io/cookbooks/windows)
* [ohai](https://supermarket.chef.io/cookbooks/ohai)
* [yum-epel](https://supermarket.chef.io/cookbooks/yum-epel)
* [compat_resource](https://supermarket.chef.io/cookbooks/compat_resource)

## GEMS
The following two GEMS will need to be pulled down and loaded onto the production nodes for envrionments that can't reach the outside. The `bootstrap_prereqs.sh` does this automatically.

* netaddr-1.5.1
* chef-sugar-3.4.0

## TEMPLATES
The following templates are Jinja2 based templates. The `jinja_render.py` found in `bootstrap/templates` reads the production yaml data files and runs through these files and builds the `production.json`, kickstart, linux grub and operations key files. The `erb` are Chef templates but the `jinja_render` script builds and puts those erb files in the `template/default` area of the cookbook as part of the preprocess.

* base_environment.json.j2
* bcs_bootstrap_rhel.ks.j2
* bcs_node_rhel_nonosd.ks.erb.j2
* bcs_node_rhel_osd.ks.erb.j2
* linux.cfg.j2
* operations.pub.j2

## USAGE

Ceph cluster design is beyond the scope of this README, please turn to the
public wiki, mailing lists, visit our IRC channel, or contact Red Hat:

http://ceph.com/docs/master
http://ceph.com/resources/mailing-list-irc/

This cookbook can be used to implement a chosen cluster design. Most of the configuration is retrieved from node attributes, which can be set by an environment or by a wrapper cookbook. A basic cluster configuration will need most of the following attributes:

* `node['ceph']['config']['fsid']` - the cluster UUID
* `node['ceph']['config]'['global']['public network']` - a CIDR specification of the public network
* `node['ceph']['config]'['global']['cluster network']` - a CIDR specification of a separate cluster replication network
* `node['ceph']['config]'['global']['rgw dns name']` -  the main domain of the radosgw daemon

Most notably, the configuration does _NOT_ need to set the `mon initial members`, because the cookbook does a node search to find other mons in the same environment.

The other set of attributes that this recipe needs is `node['ceph']['osd_devices']`, which is an array of OSD definitions, similar to the following:

* {'device' => '/dev/sdb'} - Use a full disk for the OSD, with a small partition for the journal
* {'type' => 'directory', 'device' => '/src/node/sdb1/ceph'} - Use a directory, and have a small file for the journal
* {'device' => '/dev/sde', 'dmcrypt' => true} - Store the data encrypted by passing --dmcrypt to `ceph-disk-prepare`
* {'device' => '/dev/sdc', 'journal' => '/dev/sdd2'} - use a full disk for the OSD with a custom partition for the journal

### Using a Policy Wrapper Cookbook

To automate setting several of these node attributes, it is recommended to use a policy wrapper cookbook. This allows the ability to use Chef Server cookbook versions along with environment version restrictions to roll out configuration changes in an ordered fashion.

It also can help with automating some settings. For example, a wrapper cookbook could peek at the list of harddrives that ohai has found and populate node['ceph']['osd_devices'] accordingly, instead of manually typing them all in:

```ruby
node.override['ceph']['osd_devices'] = node['block_device'].each.reject{ |name, data| name !~ /^sd[b-z]/}.sort.map { |name, data| {'journal' => "/dev/#{name}"} }
```

For best results, the wrapper cookbook's recipe should be placed before the Ceph cookbook in the node's runlist. This will ensure that any attributes are in place before the Ceph cookbook runs and consumes those attributes.

### Ceph Monitor

Ceph monitor nodes should use the ceph-mon role.

Includes:

* ceph-chef::default

### Ceph Metadata Server

Ceph metadata server nodes should use the ceph-mds role.

Includes:

* ceph-chef::default

### Ceph OSD

Ceph OSD nodes should use the ceph-osd role

Includes:

* ceph-chef::default

### Ceph RADOS Gateway

Ceph RADOS Gateway nodes should use the ceph-radosgw role

## ATTRIBUTES

### General

* `node['ceph']['search_environment']` - a custom Chef environment to search when looking for mon nodes. The cookbook defaults to searching the current environment
* `node['ceph']['branch']` - selects whether to install the stable, testing, or dev version of Ceph
* `node['ceph']['version']` - install a version of Ceph that is different than the cookbook default. If this is changed in a wrapper cookbook, some repository urls may also need to be replaced, and they are found in attributes/repo.rb. If the branch attribute is set to dev, this selects the gitbuilder branch to install
* `node['ceph']['extras_repo']` - whether to install the ceph extras repo. The tgt recipe requires this

* `node['ceph']['config']['fsid']` - the cluster UUID
* `node['ceph']['config']['global']['public network']` - a CIDR specification of the public network
* `node['ceph']['config']['global']['cluster network']` - a CIDR specification of a separate cluster replication network
* `node['ceph']['config']['config-sections']` - add to this hash to add extra config sections to the ceph.conf

* `node['ceph']['user_pools']` - an array of pool definitions, with attributes `name`, `pg_num` and `create_options` (optional), that are automatically created when a monitor is deployed

### Ceph MON

* `node['ceph']['config']['mon']` - a hash of settings to save in ceph.conf in the [mon] section, such as `'mon osd nearfull ratio' => '0.70'`

### Ceph OSD

* `node['ceph']['osd_devices']` - an array of OSD definitions for the current node
* `node['ceph']['config']['osd']` - a hash of settings to save in ceph.conf in the [osd] section, such as `'osd max backfills' => 2`
* `node['ceph']['config']['osd']['osd crush location']` - this attribute can be set on a per-node basis to maintain Crush map locations

### Ceph MDS

* `node['ceph']['config']['mds']` - a hash of settings to save in ceph.conf in the [mds] section, such as `'mds cache size' => '100000'`
* `node['ceph']['cephfs_mount']` - where the cephfs recipe should mount CephFS
* `node['ceph']['cephfs_use_fuse']` - whether the cephfs recipe should use the fuse cephfs client. It will default to heuristics based on the kernel version

### Ceph RADOS Gateway (RGW)
##### Note: Only supports the newer 'civetweb' version of RGW (not Apache)

* `node['ceph']['radosgw']['api_fqdn']` - what vhost to configure in the web server
* `node['ceph']['radosgw']['admin_email']` - the admin email address to configure in the web server
* `node['ceph']['radosgw']['port']` - if set, connects to the radosgw fastcgi over this port instead of a unix socket
* `node['ceph']['config']['global']['rgw dns name']` -  the main domain of the radosgw daemon, to calculate the bucket name from a subdomain

## Resources/Providers

### ceph\_client

The ceph\_client LWRP provides an easy way to construct a Ceph client key. These keys are needed by anything that needs to talk to the Ceph cluster, including RGW, CephFS, and RBD access.

#### Actions

- :add - creates a client key with the given parameters

#### Parameters

- :name - name attribute. The name of the client key to create. This is used to provide a default for the other parameters
- :caps - A hash of capabilities that should be granted to the client key. Defaults to `{ 'mon' => 'allow r', 'osd' => 'allow r' }`
- :as\_keyring - Whether the key should be saved in a keyring format or a simple secret key. Defaults to true, meaning it is saved as a keyring
- :keyname - The key name to register in Ceph. Defaults to `client.#{name}.#{hostname}`
- :filename - Where to save the key. Defaults to `/etc/ceph/ceph.client.#{name}.#{hostname}.keyring` if `as_keyring` and `/etc/ceph/ceph.client.#{name}.#{hostname}.secret` if not `as_keyring`
- :owner - Which owner should own the saved key file. Defaults to root
- :group - Which group should own the saved key file. Defaults to root
- :mode - What file mode should be applied. Defaults to '00640'

### ceph\_cephfs

The ceph\_cephfs LWRP provides an easy way to mount CephFS. It will automatically create a Ceph client key for the machine and mount CephFS to the specified location. If the kernel client is used, instead of the fuse client, a pre-existing subdirectory of CephFS can be mounted instead of the root.

#### Actions

- :mount - mounts CephFS
- :umount - unmounts CephFS
- :remount - remounts CephFS
- :enable - adds an fstab entry to mount CephFS
- :disable - removes an fstab entry to mount CephFS

#### Parameters

- :directory - name attribute. Where to mount CephFS in the local filesystem
- :use\_fuse - whether to use ceph-fuse or the kernel client to mount the filesystem. ceph-fuse is updated more often, but the kernel client allows for subdirectory mounting. Defaults to true
- :cephfs\_subdir - which CephFS subdirectory to mount. Defaults to '/'. An exception will be thrown if this option is set to anything other than '/' if use\_fuse is also true

### ceph\_pool

The ceph\_pool LWRP provides an easy way to create and delete Ceph pools.

It assumes that connectivity to the cluster is setup and that admin credentials are available from default locations, e.g. /etc/ceph/ceph.client.admin.keyring.

#### Actions

- :add - creates a pool with the given number of placement groups
- :delete - deletes an existing pool

#### Parameters

- :name - the name of the pool to create or delete
- :pg_num - number of placement groups, when creating a new pool
- :create_options - arguments for pool creation (optional)
- :force - force the deletion of an exiting pool along with any data that is stored in it

## DEVELOPING

### Style Guide

This cookbook requires a style guide for all contributions. Travis will automatically verify that every Pull Request follows the style guide.

1. Install [ChefDK](http://downloads.chef.io/chef-dk/)
2. Activate ChefDK's copy of ruby: `eval "$(chef shell-init bash)"`
3. `bundle install`
4. `bundle exec rake style`

### Testing

This cookbook uses Test Kitchen to verify functionality. A Pull Request can't be merged if it causes any of the test configurations to fail.

1. Install [ChefDK](http://downloads.chef.io/chef-dk/)
2. Activate ChefDK's copy of ruby: `eval "$(chef shell-init bash)"`
3. `bundle install`
4. `bundle exec kitchen test aio-debian-74`
5. `bundle exec kitchen test aio-ubuntu-1204`
6. `bundle exec kitchen test aio-ubuntu-1404`

## LICENSE
* Author: Chris Jones <cjones303@bloomberg.net>

* Copyright 2017, Bloomberg Finance L.P.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
