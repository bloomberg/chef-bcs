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

# This ONLY bootstraps Chef on the working vms and sets up authorization via actor maps.

# augment the previously configured nodes with our newly uploaded environments and roles
for vm in ${CEPH_CHEF_HOSTS[@]}; do
  do_on_node $vm "sudo chef-client $CHEF_CLIENT_DEBUG"
done
