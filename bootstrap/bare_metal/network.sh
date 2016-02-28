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

function node_update_network_ips {
  # You can add ipv6 if you like...
  # Set each interface IP, bring it up and set dns (google dns in this case - change it whatever you want or leave it :))
  # sudo nmcli c mod mgt-enp0s8 ipv4.addresses ${CEPH_ADAPTER_IPS[0]}/${CEPH_ADAPTER_IPS[3]} ipv4.gateway ${CEPH_ADAPTER_IPS[4]}
  # sudo nmcli c mod mgt-enp0s8 ipv4.method manual
  # sudo nmcli c mod mgt-enp0s8 ipv4.dns "8.8.8.8 8.8.4.4"

  sudo nmcli c mod enp0s8 ipv4.addresses ${CEPH_ADAPTER_IPS[0]}/${CEPH_ADAPTER_IPS[2]} ipv4.gateway ${CEPH_ADAPTER_IPS[3]}
  sudo nmcli c mod enp0s8 ipv4.method manual
  sudo nmcli c mod enp0s8 ipv4.dns "8.8.8.8 8.8.4.4"

  sudo nmcli c mod enp0s9 ipv4.addresses ${CEPH_ADAPTER_IPS[1]}/${CEPH_ADAPTER_IPS[2]} ipv4.gateway ${CEPH_ADAPTER_IPS[4]}
  sudo nmcli c mod enp0s9 ipv4.method manual
  sudo nmcli c mod enp0s9 ipv4.dns "8.8.8.8 8.8.4.4"

  # sudo nmcli c up mgt-enp0s8
  sudo nmcli c up enp0s8
  sudo nmcli c up enp0s9
}

function node_remove_new_network_connections {
  # sudo nmcli con delete mgt-enp0s8
  sudo nmcli con delete enp0s8
  sudo nmcli con delete enp0s9
}

function node_remove_default_network_connections {
  sudo nmcli con delete 'enp0s0f0'
  sudo nmcli con delete 'enp0s0f1'
  # sudo nmcli con delete 'Wired connection 3'
}

function node_add_network_connections {
  # sudo nmcli con add type ethernet con-name mgt-enp0s8 ifname enp0s8
  sudo nmcli con add type ethernet con-name enp0s8 ifname enp0s8
  sudo nmcli con add type ethernet con-name enp0s9 ifname enp0s9
}
