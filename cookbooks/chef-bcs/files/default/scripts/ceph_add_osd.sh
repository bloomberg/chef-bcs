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
cluster=${3:-ceph}
fs=${4:-xfs}

if [[ -z $data ]]; then
  echo 'Must pass in a valid data device name (i.e., /dev/sdl).'
  exit 1
fi

if [[ -z $journal ]]; then
  echo 'Must pass in a valid journal device name (i.e., /dev/sdn11 - if you want to use the same journal OR /dev/sdn and a new partition on the device will be created).'
  exit 1
fi

if [[ -z $cluster ]]; then
  echo 'Must pass in a valid cluster name (defaults to `ceph`).'
  exit 1
fi

if [[ -z $fs ]]; then
  echo 'Must pass in a valid fs-type name (defaults to `xfs`).'
  exit 1
fi

# NOTE: If this scripts bails here then just run the two commands below with the correct parameters! This is for safety!!
found=$(parted --script $data print 2>/dev/null | egrep -c 'ceph')
if [[ $found -eq 0 ]]; then
  ceph-disk -v prepare --cluster $cluster --fs-type $fs $data $journal
  ceph-disk -v activate $data
else
  echo 'Device: $data is already allocated!'
  exit 1
fi
