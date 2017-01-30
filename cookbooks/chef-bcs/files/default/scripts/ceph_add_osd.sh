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

# NOTE: If Journal partition is already allocated (a data drive has gone down and you're replacing it) then specify the number
# after the Journal device name (i.e, /dev/sdn11). However, if not already allocated then just the device name is all
# that is needed (i.e., /dev/sdn) and a partition will be indexed and allocated.

data=$1
journal=$2
cluster=${3:ceph}
fs=${4:xfs}

if [[ -z $data ]]; then
  echo 'Must pass in a valid data device name.'
  exit 1
fi

if [[ -z $journal ]]; then
  echo 'Must pass in a valid journal device name.'
  exit 1
fi

if [[ -z $cluster ]]; then
  echo 'Must pass in a valid cluster name.'
  exit 1
fi

if [[ -z $fs ]]; then
  echo 'Must pass in a valid fs-type name.'
  exit 1
fi

found=$(parted --script $data print | egrep -sq '^ 1.*ceph')
if [[ $found -eq 0 ]]; then
  # Remove the device if needed first so that you can rescan
  # echo 1 > /sys/block/sdX/device/delete
  is_device=$(echo '$data' | egrep '/dev/(([a-z]{3,4}[0-9]$)|(cciss/c[0-9]{1}d[0-9]{1}p[0-9]$))')
  ceph-disk -v prepare --cluster $cluster --fs-type $fs $data $journal
  if [[ ! -z $is_device ]]; then
    ceph-disk -v activate $data1
  else
    ceph-disk -v activate $data
  fi

  # Redhat/CentOS
  sysvinit=$(find /var/lib/ceph/osd -name sysvinit)
  if [[ ! -z $sysvinit ]]; then
    sudo service ceph start osd
  else
    upstart=$(find /var/lib/ceph/osd -name upstart)
    if [[ ! -z $upstart ]]; then
      sudo service ceph start osd
    else
      sudo systemctl start ceph osd
    fi
  fi
else
  echo 'Device: $data is already allocated!'
  exit 1
fi
