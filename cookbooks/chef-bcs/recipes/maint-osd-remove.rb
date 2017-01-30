#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
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

# C-A-U-T-I-O-N! This will remove ALL data and zap the drive. MAKE SURE to reweight the OSD device down to 0
# BEFORE removing it from the Ceph control with this recipe!
# NOTE: Depending on the amount of data on the device: you can reweight to 0 if only a small amount of data exists on
# the device else reweight in very small increments down to 0 (can be time consuming) so that it doesn't "crush"
# your performance (pun intended :))!

include_recipe 'chef-bcs::ceph-conf'

# This recipe sets up ceph osd removal info for the lower level osd_remove_zap recipe
node.default['ceph']['osd']['remove'] = node['chef-bcs']['ceph']['osd']['remove']

# Run the lower level ceph recipe
include_recipe 'ceph-chef::maint_osd_remove_zap'
