#!/bin/bash
#
# Author: Chris Jones <cjones303@bloomberg.net>
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

# IMPORTANT: This script needs to run on the Ceph node where the OSD lives!

set -e

osd=$1

if [[ -z $osd ]]; then
  echo 'Must pass in a valid OSD number.'
  exit 1
fi

# Step -1:
# NOTE: On some hardware platforms, udev rules have `hot replaceable` drives showing up as a different device name.
# For example, /dev/sdk may have failed but when replaced it could show up as /dev/sdo or something. You can modify
# udev rules or ignore it for now. Meaning, run through the below using the new device name (i.e., /dev/sdo) and
# re-use the journal device as normal. If the node is 're-cheffed' then nothing will happen because the 'deployed'
# check is enabled. If the node happens to reboot then the default udev rules will enumerate the devices as expected
# with the device going back to the name of /dev/sdk. Again, this may not be the case for all hardware and controllers.

# Step 0:
# NOTE: Make sure data device is zapped if not already. If you run `sudo ceph-disk list` and it reports a failure then it may
# have old Ceph data partition. In this case (be careful), zap the data drive first.
#   sudo dd if=/dev/zero of=/dev/<whatever data device> bs=512 count=1 conv=notrunc
#   sduo sgdisk --zap-all /dev/<whatever data device>

# Step 1: IMPORTANT - Start with the lowest OSD number if multiple drive fails. Ceph reuses empty OSD sequence. For example,
# if OSD.100 and OSD.150 fails then replace OSD.100 first and then OSD.150. This makes things easier to manage.
# ceph_remove_osd.sh $osd

# Step 2:
# Wait for Ceph to rebalance

# Step 3: NOTE: This will format the disk and create the OSD. Nothing really happens to data until the crushmap is set.
# Do `sudo ceph-disk list` to find the journal of the device
# ceph_add_osd.sh $data_device $journal_device

# Step 4: NOTE: Get the weight from `ceph osd tree` assuming the same size disk
# ceph_osd_crush_weight_create_move.sh $osd $rack $weight

# Step 5:
# sudo service ceph start
