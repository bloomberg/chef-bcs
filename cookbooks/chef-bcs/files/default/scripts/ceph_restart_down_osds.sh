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

# IMPORTANT: This script needs to run from a Ceph node!

# NOTE: This script *assumes* that you have a user and user ssh key on each node!
# For example, the default user below is 'operations' so change that to whatever user you wish it to be.

# NOTE: I suggest that you set the nodown attribute in ceph *before* you run any ceph command that will impact
# OSDs. For example, before running this (assuming nodown is not already set), call: 'ceph osd set nodown'
# This will keep the HEALTH_WARNING flag set but keep the OSDs from being marked down while PGs get moved around.
# After everything settles down you can then call: 'ceph osd unset nodown' and the HEALTH_OK should appear.

for i in $(ceph osd tree | awk '/down/ {print $1}'); do
  host=$(ceph osd find $i | awk -F\" '$2 ~ /host/ {print $4}')
  ssh -t -o StrictHostKeyChecking=no operations@$host "sudo service ceph start osd.$i"
done
