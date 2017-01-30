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

# IMPORTANT: This script needs to run on the Ceph node where the Journal lives!
set -e

journal_disk=$1

if [[ -z $journal_disk ]]; then
  echo "Must pass in a valid journal device such as /dev/sdn etc."
  exit 1
fi

# Default - 20GB approx since doing aligment...
journal_size=${2:-20000}

# Default alignment for SSD. Check your mfg for recommended alignment offset.
journal_alignment_offset=2048
journal_start=$journal_alignment_offset
journal_end=$(($journal_size*$journal_alignment_offset+$journal_alignment_offset-1))
part=1

for osd_id in $(ls /var/lib/ceph/osd | awk -F\- '{print $2}'); do
  journal_uuid=$(sudo cat /var/lib/ceph/osd/ceph-$osd_id/journal_uuid)
  sudo sgdisk --new=$part:$journal_start:$journal_end --change-name=$part:'ceph journal' --typecode=$part:$journal_uuid --mbrtogpt -- $journal_disk
  sudo ceph-osd --mkjournal -i $osd_id
  sudo service ceph start osd.$osd_id
  journal_start=$(($journal_end+1))
  part=$((part+1))
  journal_end=$(($journal_size*$journal_alignment_offset*$part+$journal_alignment_offset-1))
done
