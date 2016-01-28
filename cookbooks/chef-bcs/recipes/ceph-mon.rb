#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
# Recipe:: ceph-mon
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

# This recipe sets up ceph monitor configuration information needed by the ceph cookbook recipes
# If you want to quickly start a cluster then can specify one or more hosts in 'mon_initial_members' to get a faster
# quorum but is really not necessary if fully automated.
# node.default['ceph']['config']['mon_initial_members'] = node['hostname']  # quorum of 1 example

# Example of how to customize ceph.conf for the 'mon' section
node.default['ceph']['config']['mon']['mon pg warn max per osd']=0
node.default['ceph']['config']['mon']['mon osd full ratio']=0.90
node.default['ceph']['config']['mon']['mon osd nearfull ratio']=0.80

# Another (better) example is in the 'roles' section in ceph-mon-install. It contains role override attributes of the
# same settings as above.
