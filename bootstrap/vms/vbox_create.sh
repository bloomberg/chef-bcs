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

function update_network_interfaces {
  echo ${CEPH_CHEF_HOSTS[@]}
  echo '---------------------------------------------'

  for vm in ${CEPH_CHEF_HOSTS[@]}; do
      node_update_network_interfaces $vm
  done
}

# This function calls a function by the same name on the given node to update the interfaces
function node_update_network_interfaces {
  local node=$1
  vagrant ssh $node -c ". network.sh && node_update_network_interfaces"
  vagrant ssh $node -c ". network.sh && . network_setup.sh && node_update_network_ips"
}

###################################################################
# Function to create all VMs
function create_vbox_vms {
  echo "Shutting down and unregistering VMs from VirtualBox..."
  $REPO_ROOT/bootstrap/vms/vbox_clean.sh
  ssh-keygen -b 2048 -t rsa -f $REPO_ROOT/bootstrap/vms/chef-bcs -q -N ""

  # Create the nodes (not bootstrap - it should have already been created before calling this function)


}

# Only execute functions if being run and not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  remove_DHCPservers

  create_vbox_vms

  # These files are created during the vagrant build 'create_vagrant_vms' and reside in the vagrant_scripts directory
  source $REPO_ROOT/bootstrap/vms/ceph_chef_hosts.env
  source $REPO_ROOT/bootstrap/vms/ceph_chef_adapters.env
  source $REPO_ROOT/bootstrap/vms/ceph_chef_bootstrap.env

  config_networks
fi
