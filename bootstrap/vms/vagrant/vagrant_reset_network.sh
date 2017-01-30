#!/bin/bash
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

# The script is just here to reset the network interfaces for the cluster if needed
set -e

# It's safe to put this here since this script is for vagrant only
export BOOTSTRAP_CHEF_ENV={$BOOSTRAP_CHEF_ENV:-"vagrant"}

# Important
source vagrant_base.sh

function reset_network_interfaces {
    for vm in ${CEPH_CHEF_HOSTS[@]}; do
        node_reset_network_interfaces $vm
    done
}

# This function cleans the network interfaces and then resets them. If you clone the VMs and then refresh the
# mac address for the adapters (must do in some cases) then default connection settings are added back in
# so, the previously updated connection names must be removed and the process of updating done again.
# This function calls a function called node_update_network_interfaces on the given node to update the interfaces
function node_reset_network_interfaces {
    local node=$1
    vagrant ssh $node -c ". network.sh && node_update_network_interfaces"
    vagrant ssh $node -c ". network.sh && . network_setup.sh && node_update_network_ips"
}

# Only execute functions if being run and not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  reset_network_interfaces
fi
