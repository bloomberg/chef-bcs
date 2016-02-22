#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
# Recipe:: ceph-rgw
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

# This is one way to set node default values within a higher level area. However, role default or override
# attribute values are normally a better choice but in this case we want to set the 'rgw dns name' from
# another node attribute value.

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

# node.default['ceph']['config']['radosgw'] = node['chef-bcs']['ceph']['config']['radosgw']
