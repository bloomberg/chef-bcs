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

# IMPORTANT: This script DOES NOT shut the ceph-osd services down for the given OSDs. It is assumed that they are
# already down either by you or the node has failed.

# IMPORTANT: This script will remove ALL OSDs for the given node where the OSDs are marked down.
# The default number of drives in the given node is 12 but you can pass in however many drives are in your system
# for example, ./remove_all_osds_for_node.sh mynodename 36

# AFTER you have removed all of the OSDs for the given node then you can PXE boot the node again and if that fails you
# will need to replace it!!

# If anything fails then the script will exit. You can then run ./remove_osd.sh for the specific OSD one at a time.
set -e

ceph osd set nodown
ceph osd set noout
ceph osd set norecover
ceph osd set nobackfill
ceph osd set norebalance
