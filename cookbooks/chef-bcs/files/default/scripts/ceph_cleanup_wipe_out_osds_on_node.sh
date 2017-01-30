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

# DANGER - DANGER - DANGER!!!!

# This assumes you have already stoppped and/or removed Ceph.

# Wipe the data and partions from a device at once.
# dd if=/dev/zero of=/dev/sda bs=512 count=1 conv=notrunc

# Replace devices to fit your environment

for i in a b c d e f g h i j k l; do
  dd if=/dev/zero of=/dev/sd$i bs=512 count=1 conv=notrunc
  sgdisk --zap-all /dev/sd$i
done
