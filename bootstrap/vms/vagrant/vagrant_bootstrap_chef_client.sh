#!/bin/bash
#
# Author: Chris Jones <cjones303@bloomberg.net>
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

# Reverse cloning of cloned VMs so as to make them active in a clean state (same as the point where they were cloned).

# NOTE: MUST execute from VAGRANT directory of project

source vagrant_base.sh

# Only runs the chef-client on the bootstrap nodes. This occurs in the following sequence:
# 1. vagrant_bootstrap_chef.sh
# 2. vagrant_bootstrap_chef_vms.sh
# 3. vagrant_bootstrap_chef_client.sh
# Then do the mon, osd, rgw etc.

# TODO: Make OS check here to do for Ubuntu or RHEL based...
do_on_node $CEPH_CHEF_BOOTSTRAP "sudo cp /ceph-files/cobbler/isos/centos-7-x86_64-minimal.iso /tmp"

do_on_node $CEPH_CHEF_BOOTSTRAP "sudo chef-client"
