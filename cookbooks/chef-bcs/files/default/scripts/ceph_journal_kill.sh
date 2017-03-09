#!/bin/bash
#
# Author:: Chris Jones <cjones303@bloomberg.net>
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

# Script takes 2 parameter: journal device, partition

dev=$1
partition=${2:-0}

if [[ -z $dev ]]; then
  echo "Must specify the correct Ceph Journal device!"
  exit 1
fi

echo "Device: $dev"
echo "Partition: $partiion"

# TODO: Finish...

# Wipe the data and partions from a device at once.
# dd if=/dev/zero of=/dev/sda bs=512 count=1 conv=notrunc

for i in $(parted --machine -- $dev print); do
  part=$(echo $i | grep ceph | grep ^[0-9] | awk -F: '{print $1}')

  # Destroy partition if it matches - DANGER!
  if [[ $partition -eq 0 || $partition -eq $part ]]; then
      echo "Nothing yet... WIP"
      # Need to find which journal is associated with the given OSD and then what partition number it is. Then delete the given partition
  fi
done
