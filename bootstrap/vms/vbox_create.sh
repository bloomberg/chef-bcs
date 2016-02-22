#!/bin/bash
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

# Exit immediately if anything goes wrong, instead of making things worse.
set -e

# Important
source vbox_functions.sh

# Did not call the remove_array_element from bash_functions.sh here because we don't want to modify the CEPH_CHEF_HOSTS
delete=($CEPH_CHEF_BOOTSTRAP)
# All of the VMs for Ceph with the bootstrap node removed.
ceph_vms=("${CEPH_CHEF_HOSTS[@]/$delete}")

###################################################################
# Function to create all VMs
function create_vbox_vms {
  echo "Generating key and building VMs for PXE ..."
  $REPO_ROOT/bootstrap/vms/vbox_clean.sh
  ssh-keygen -b 2048 -t rsa -f $REPO_ROOT/bootstrap/vms/chef-bcs -q -N ""

  # Create the nodes (not bootstrap - it should have already been created before calling this function)
  # Don't start the nodes here. These nodes are setup for pxe booting so when they start they will begin
  # pxe booting. Also, will run the boot sequentially because of memory on the host.
  for vm in ${ceph_vms[@]}; do

  done
}

function boot_vbox_vms {
  for vm in ${ceph_vms[@]}; do

  done
}

# Only execute functions if being run and not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  remove_DHCPservers

  create_vbox_vms

  boot_vbox_vms
fi
