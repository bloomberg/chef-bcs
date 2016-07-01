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

set -e

# SUDO this script
# Device scsci number 0-N

host=${1:0}
channel=${2:-}
device=${3:-}

if [[ -z $device ]]; then
  echo "Must pass in a valid scsi device number (0-N) or a '-'."
  exit 1
fi

# IF the device is activated this should cause a scsi rescan. If the devices does not show then make sure it is
# enabled via HBA vendor specific commands maybe.

# You can look at other scsi device information with:
# cat /proc/scsi/scsi
# This show the Host/Channel/Id/Lun information (Lun is always 0 in this environment)

# NOTE: This works better than rescan-scsi-bus.sh which comes with the sg3_utils

# You can also just call this script like (this will scan everything for host 0):
# ./add_device_to_os.sh 0 - -
# OR
# ./add_device_to_os.sh (let the defaults do the work)

# No lun so default to -
echo "$channel $device -" > /sys/class/scsi_host/host$host/scan
