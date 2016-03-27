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

# Comment out the two lines below to go back to the latest hammer point release
# node.default['ceph']['branch'] = 'testing'
# node.default['ceph']['version'] = 'infernalis'

include_recipe 'chef-bcs::ceph-conf'

node.default['ceph']['version'] = node['chef-bcs']['ceph']['repo']['version']['name']
node.default['ceph']['branch'] = node['chef-bcs']['ceph']['repo']['version']['branch']

node.default['ceph']['repo']['create'] = node['chef-bcs']['ceph']['repo']['create']
