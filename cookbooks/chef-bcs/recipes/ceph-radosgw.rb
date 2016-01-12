#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
# Recipe:: ceph-rgw
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

# This is one way to set node default values within a higher level area. However, role default or override
# attribute values are normally a better choice but in this case we want to set the 'rgw dns name' from
# another node attribute value.

# This recipe sets up ceph rgw configuration information needed by the ceph cookbook recipes
node.default['ceph']['config']['rgw']['rgw dns name'] = node['chef-bcs']['domain_name']

# An example of using sharding for RGW (small value for testing...). Putting it in the 'global' section.
# Default is 0 - no sharding index. Anything > 0 will initiate index sharding.
node.default['ceph']['config']['global']['rgw override bucket index max shards']=0

node.default['ceph']['radosgw']['port'] = node['chef-bcs']['radosgw']['port']
