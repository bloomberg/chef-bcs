#!/bin/bash
#
# Author: Chris Jones <cjones303@bloomberg.net>
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

source vagrant_base.sh

# Handles the install, start and key gathering for Ceph Monitor nodes.
# Step 1
for vm in ${ceph_vms[@]}; do
  do_on_node $CEPH_CHEF_BOOTSTRAP "$KNIFE node run_list add $vm.$BOOTSTRAP_DOMAIN 'role[ceph-mon-install]'"
  do_on_node $vm "sudo chef-client"
done

# Step 2
for vm in ${ceph_vms[@]}; do
  do_on_node $CEPH_CHEF_BOOTSTRAP "$KNIFE node run_list add $vm.$BOOTSTRAP_DOMAIN 'role[ceph-mon-start]'"
  do_on_node $vm "sudo chef-client -o 'role[ceph-mon-start]'"
done

# Step 3
for vm in ${ceph_vms[@]}; do
  sleep 3 # Let things settle down from the mon-start
  do_on_node $CEPH_CHEF_BOOTSTRAP "$KNIFE node run_list add $vm.$BOOTSTRAP_DOMAIN 'role[ceph-mon-keys]'"
  do_on_node $vm "sudo chef-client -o 'role[ceph-mon-keys]'"
done
