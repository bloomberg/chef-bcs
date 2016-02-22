#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
# Recipe:: ceph-osd
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

# This recipe sets up ceph osd configuration information needed by the ceph cookbook recipes
node.default['ceph']['osd']['devices'] = node['chef-bcs']['ceph']['osd']['devices']

# node.default['ceph']['config']['osd'] = node['chef-bcs']['ceph']['config']['osd']

# PG         "pgp_auto_adjust" : false,

# Note: The default size of replica is 3 but since we only have 2 OSD devices then we need to change
# replica size down to 2 as well. This only applies when there are a few OSD devices.
# This is done in the pools settings.

# NOTE: The entries below are examples of how to use Chef to remove and add devices. The data will need to be added in
# the "osd": section of "ceph": in the given environment file just like "devices": are entered.
# "remove": {
#   "devices": [
#     { "node": "ceph-vm1", "osd": 0, "zap": true, "partition": 1, "data": "/dev/sdb", "journal": "/dev/sdf" }
#   ]
# },
# "add": {
#   "devices": [
#     { "node": "ceph-vm3", "data": "/dev/sde", "type": "hdd", "journal": "/dev/sde" }
#   ]
# }
