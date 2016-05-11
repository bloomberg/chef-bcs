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

# IMPORTANT: This file is currently called in vbox_functions in the function called config_networks
# It's done there for now because it already has the VMs down for network adapters so it made since
# to put it there so that we would not have to shutdown the vms again.

#shutdown_vms

vm_dir=$(vbox_dir)
# Items that need addressing...
controller=$VBOX_SATA_CONTROLLER
dev=0

echo "Starting drive attachment..."

for vm in ${CEPH_OSD_HOSTS[@]}; do
  echo $vm
  for i in $(seq 0 $CEPH_OSD_DRIVES); do
    vbox_delete_hdd $vm "$controller" $dev $((3+$i)) "$vm_dir/$vm/$vm-osd-$i.vdi"
    vbox_create_hdd "$vm_dir/$vm/$vm-osd-$i.vdi" 20480
    vbox_add_hdd $vm "$controller" $dev $((3+$i)) "$vm_dir/$vm/$vm-osd-$i.vdi"
  done

  # Add 1st Journal drive
  vbox_delete_hdd $vm "$controller" $dev 10 "$vm_dir/$vm/$vm-osd-journal.vdi"
  vbox_create_hdd "$vm_dir/$vm/$vm-osd-journal.vdi" 40960
  vbox_add_hdd $vm "$controller" $dev 10 "$vm_dir/$vm/$vm-osd-journal.vdi"

  # Add 2nd Journal drive - only used for testing raid1 with os sharing journals
  #vbox_delete_hdd $vm "$controller" $dev 11 "$vm_dir/$vm/$vm-osd-journal.vdi"
  #vbox_create_hdd "$vm_dir/$vm/$vm-osd-journal.vdi" 40960
  #vbox_add_hdd $vm "$controller" $dev 11 "$vm_dir/$vm/$vm-osd-journal.vdi"
done
