#!/bin/bash
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

# Exit immediately if anything goes wrong, instead of making things worse.
set -e

function node_update_network_interfaces {
  set +e
  node_remove_default_network_connections
  node_remove_new_network_connections
  node_add_network_connections
  set -e
}

function node_modify_network_interfaces {
  IFS_OLD=$IFS
  IFS=$'\n'
  ifaces=($(sudo nmcli -t -f NAME,UUID,DEVICE c s))
  for ifs in ${ifaces[@]}; do
    _name=$(echo $ifs | awk -F: '{print $1}')
    _uuid=$(echo $ifs | awk -F: '{print $2}')
    _device=$(echo $ifs | awk -F: '{print $3}')
    echo $_name
    echo $_uuid
    echo $_device
    # You could also delete the connections and then add new ones
    # if [[ $_device == "enp0s8" || ($_device == "--" && $_name == "Wired connection 1") ]]; then
    #    sudo nmcli c modify $_uuid connection.id 'mgt-enp0s8'
    # fi
    if [[ $_device == "enp0s8" || ($_device == "--" && $_name == "Wired connection 1") ]]; then
        sudo nmcli c modify $_uuid connection.id 'cfe-enp0s8'
    fi
    if [[ $_device == "enp0s9" || ($_device == "--" && $_name == "Wired connection 2") ]]; then
        sudo nmcli c modify $_uuid connection.id 'cbe-enp0s9'
    fi
  done
  IFS=$IFS_OLD
}

function node_update_network_ips {
  # You can add ipv6 if you like...
  # Set each interface IP, bring it up and set dns (google dns in this case - change it whatever you want or leave it :))
  # sudo nmcli c mod mgt-enp0s8 ipv4.addresses ${CEPH_ADAPTER_IPS[0]}/${CEPH_ADAPTER_IPS[3]} ipv4.gateway ${CEPH_ADAPTER_IPS[4]}
  # sudo nmcli c mod mgt-enp0s8 ipv4.method manual
  # sudo nmcli c mod mgt-enp0s8 ipv4.dns "8.8.8.8 8.8.4.4"

  sudo nmcli c mod cfe-enp0s8 ipv4.addresses ${CEPH_ADAPTER_IPS[0]}/${CEPH_ADAPTER_IPS[2]} ipv4.gateway ${CEPH_ADAPTER_IPS[3]}
  sudo nmcli c mod cfe-enp0s8 ipv4.method manual
  sudo nmcli c mod cfe-enp0s8 ipv4.dns "8.8.8.8 8.8.4.4"

  sudo nmcli c mod cbe-enp0s9 ipv4.addresses ${CEPH_ADAPTER_IPS[1]}/${CEPH_ADAPTER_IPS[2]} ipv4.gateway ${CEPH_ADAPTER_IPS[4]}
  sudo nmcli c mod cbe-enp0s9 ipv4.method manual
  sudo nmcli c mod cbe-enp0s9 ipv4.dns "8.8.8.8 8.8.4.4"

  # sudo nmcli c up mgt-enp0s8
  sudo nmcli c up cfe-enp0s8
  sudo nmcli c up cbe-enp0s9
}

function node_remove_new_network_connections {
  # sudo nmcli con delete mgt-enp0s8
  sudo nmcli con delete cfe-enp0s8
  sudo nmcli con delete cbe-enp0s9
}

function node_remove_default_network_connections {
  sudo nmcli con delete 'Wired connection 1'
  sudo nmcli con delete 'Wired connection 2'
  # sudo nmcli con delete 'Wired connection 3'
}

function node_add_network_connections {
  # sudo nmcli con add type ethernet con-name mgt-enp0s8 ifname enp0s8
  sudo nmcli con add type ethernet con-name cfe-enp0s8 ifname enp0s8
  sudo nmcli con add type ethernet con-name cbe-enp0s9 ifname enp0s9
}
