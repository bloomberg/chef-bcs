#!/bin/bash
#
# Author:: Chris Jones <cjones303@bloomberg.net>
#
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

# DANGER - DANGER - DANGER!!!!

# This assumes you have already stopped and/or removed Ceph.

# Wipe the data and partions from a device at once.
# dd if=/dev/zero of=/dev/sda bs=512 count=1 conv=notrunc
set -e

dev=$1

if [[ -z $dev ]]; then
  echo "Must pass in a valid device."
  exit 1
fi

for i in $(parted $dev print | grep ceph | awk '{print $1}'); do
  echo "Deleting partition: $i"
  parted $dev rm $i > /dev/null 2>&1
done
