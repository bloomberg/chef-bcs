#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
# Recipe:: ceph-mon
#
# Copyright 2017, Bloomberg Finance L.P.
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

# This recipe sets up ceph monitor configuration information needed by the ceph cookbook recipes
# If you want to quickly start a cluster then can specify one or more hosts in 'mon initial members' to get a faster
# quorum but it's really not necessary if fully automated.
# node.default['ceph']['config']['global']['mon initial members'] = node['hostname']  # quorum of 1 example

# Defined in the environment json file
# node.default['ceph']['config']['mon'] = node['chef-bcs']['ceph']['config']['mon']

# Example: "mon initial members": "10.121.1.3:6789, 10.121.1.4:6789, 10.121.1.5:6789",

include_recipe 'chef-bcs::ceph-conf'
