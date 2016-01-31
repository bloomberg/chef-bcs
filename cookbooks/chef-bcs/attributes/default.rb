#
# Copyright 2015, Bloomberg Finance L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

###########################################
#
#  General configuration for this cluster
#
###########################################
# Change these to fit your organization
default['chef-bcs']['country'] = "US"
default['chef-bcs']['state'] = "NY"
default['chef-bcs']['location'] = "New York"
default['chef-bcs']['organization'] = "Bloomberg"

# ulimits for libvirt-bin
default['chef-bcs']['libvirt-bin']['ulimit']['nofile'] = 4096
# Region name for this cluster
default['chef-bcs']['region_name'] = node.chef_environment
# Domain name for this cluster (used in many configs)
default['chef-bcs']['domain_name'] = "ceph.example.com"

###########################################
#
# Package versions
#
###########################################

case node['platform']
when 'ubuntu'
  default['chef-bcs']['init_style'] = 'upstart'
else
  default['chef-bcs']['init_style'] = 'sysvinit'
end

case node['platform_family']
when 'debian'
    default['chef-bcs']['os']['version'] = '14.04'
    default['chef-bcs']['ceph']['version'] = '0.94.4-1trusty'
    default['chef-bcs']['ceph']['version_number'] = '0.94.4'
when 'rhel'
    default['chef-bcs']['os']['version'] = 'rhel7.1'  # centos-7.1 for CentOS
    # The default for Redhat. The default for CentOS is el7 and is overridden in the environment json file.
    default['chef-bcs']['ceph']['version'] = '0.94.4-0.el7'
    default['chef-bcs']['ceph']['version_number'] = '0.94.4'
end

###########################################
#
#  Flags security
#
###########################################
# sshd_config
default['chef-bcs']['security']['sshd']['Permit_Root_Login'] = 'no'  # Valid values (yes, no)
default['chef-bcs']['security']['sshd']['Login_Grace_Time'] = '2m'
default['chef-bcs']['security']['sshd']['Max_Auth_Tries'] = 6
default['chef-bcs']['security']['sshd']['Max_Sessions'] = 10

###########################################
#
#  Flags firewall (firewall cookbook)
#
###########################################
default['firewall']['allow_ssh'] = true

###########################################
#
#  Flags network
#
###########################################
default['chef-bcs']['network']['public']['mtu'] = 1500
default['chef-bcs']['network']['cluster']['mtu'] = 9000

###########################################
#
#  Flags to enable/disable ceph cluster features
#
###########################################
# This will enable the networking test scripts
default['chef-bcs']['enabled']['network_tests'] = true

# If radosgw_cache is enabled, default to 20MB max file size
default['chef-bcs']['radosgw']['cache_max_file_size'] = 20000000
default['chef-bcs']['radosgw']['port'] = 80
default['chef-bcs']['restapi']['port'] = 5080

###########################################
#
#  Ceph settings for the cluster
#
###########################################
default['chef-bcs']['ceph']['encrypted'] = false

# To use apache instead of civetweb, make the following value anything but 'civetweb'
default['chef-bcs']['ceph']['chooseleaf'] = "host"
default['chef-bcs']['ceph']['pgp_auto_adjust'] = false
# Need to review...
default['chef-bcs']['ceph']['pgs_per_node'] = 1024
# Journal size could be 10GB or higher in some cases
default['chef-bcs']['ceph']['journal_size'] = 10000
# The 'portion' parameters should add up to ~100 across all pools

# NOTE: The default pool type is replicated. If you wish to change to Erasure Coding then override the node
# settings in ceph-radosgw.rb recipe.

# If you are about to make a big change to the ceph cluster
# setting to true will reduce the load form the resulting
# ceph rebalance and keep things operational.
# See wiki for further details.
default['chef-bcs']['ceph']['rebalance'] = false

# Set the default niceness of Ceph OSD and monitor processes
# May only need to set these if you're running a converged cluster with OpenStack and Ceph on SAME hardware nodes
default['chef-bcs']['ceph']['osd_niceness'] = -10
default['chef-bcs']['ceph']['mon_niceness'] = -10

# NOTE: See environment file for given environment to see other cobbler variables.
default['chef-bcs']['cobbler']['server'] = nil
default['chef-bcs']['cobbler']['http_port'] = 80
default['chef-bcs']['cobbler']['https_port'] = 443
default['chef-bcs']['cobbler']['xmlrpc_port'] = 25151
# IMPORTANT: The name of this distro *MUST* match the 'prerequisite' script that downloads dependencies
default['chef-bcs']['cobbler']['distro'] = 'centos-7-x86_64-minimal.iso'
