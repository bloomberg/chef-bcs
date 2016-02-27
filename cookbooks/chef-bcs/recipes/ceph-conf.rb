#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
#
# Copyright 2016, Bloomberg Finance L.P.
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

# This recipe allows to specify overrides to the ceph.conf settings in ceph-chef cookbook.
# Some values are part of 'ceph''config''global' which will create a k,v pair as is.
# Some values are specific variables that need to be set instead.

# NOTE: This file also updates the data in the ceph-chef cookbook
node.default['ceph']['cluster'] = node['chef-bcs']['ceph']['cluster']

node.default['ceph']['network']['public']['cidr'] = node['chef-bcs']['network']['public']['cidr']
node.default['ceph']['network']['cluster']['cidr'] = node['chef-bcs']['network']['cluster']['cidr']

# An example of using sharding for RGW (small value for testing...). Putting it in the 'global' section.
# Default is 0 - no sharding index. Anything > 0 will initiate index sharding.
node.default['ceph']['config'] = node['chef-bcs']['ceph']['config']

# This recipe sets up ceph osd configuration information needed by the ceph cookbook recipes
node.default['ceph']['osd']['devices'] = node['chef-bcs']['ceph']['osd']['devices']

# This recipe sets up ceph rgw configuration information needed by the ceph cookbook recipes
node.default['ceph']['radosgw']['dns_name'] = node['chef-bcs']['domain_name']
node.default['ceph']['radosgw']['port'] = node['chef-bcs']['ceph']['radosgw']['port']
node.default['ceph']['radosgw']['keystone']['auth'] = node['chef-bcs']['ceph']['radosgw']['keystone']['auth']
node.default['ceph']['radosgw']['keystone']['accepted_roles'] = node['chef-bcs']['ceph']['radosgw']['keystone']['accepted_roles']
node.default['ceph']['radosgw']['keystone']['token_cache_size'] = node['chef-bcs']['ceph']['radosgw']['keystone']['token_cache_size']
node.default['ceph']['radosgw']['keystone']['revocation_interval'] = node['chef-bcs']['ceph']['radosgw']['keystone']['revocation_interval']
node.default['ceph']['radosgw']['keystone']['admin']['token'] = node['chef-bcs']['ceph']['radosgw']['keystone']['admin']['token']
node.default['ceph']['radosgw']['keystone']['admin']['url'] = node['chef-bcs']['ceph']['radosgw']['keystone']['admin']['url']
node.default['ceph']['radosgw']['keystone']['admin']['port'] = node['chef-bcs']['ceph']['radosgw']['keystone']['admin']['port']
node.default['ceph']['radosgw']['rgw_num_rados_handles'] = node['chef-bcs']['ceph']['radosgw']['rgw_num_rados_handles']
node.default['ceph']['radosgw']['civetweb_num_threads'] = node['chef-bcs']['ceph']['radosgw']['civetweb_num_threads']

node.default['ceph']['restapi']['port'] = node['chef-bcs']['ceph']['restapi']['port']
