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

# IMPORTANT: This script needs to run on the Ceph node where the OSD lives!
set -e

osd=$1

if [[ -z $osd ]]; then
  echo 'Must pass in a valid OSD number.'
  exit 1
fi

# Stop any monitoring
sudo systemctl stop zabbix-agent
sudo systemctl stop collectd

# Step 1 (reweight down to 0.0)
# Reweighting down to 0.0 all at once is not a good thing unless there is only a small
# amount of data. Otherwise, you will get a lot of rebalancing that can degrade
# cluster's performance.
# *IF* the OSD has a number of objects then pick a smaller reweight of something less than
# 1.0. For example, ceph osd crush reweight osd.XXX .90. If that goes quickly then you
# can most likely increase the lowering reweight until you see it beginning to hit
# the cluster performance. In that case, back down on the delta each time. Continue
# with this process until you hit a final 0.0 reweight.

# Step 2 (on the node where the OSD resides)
ceph osd out $osd
# NOTE: Can change the next line to ssh into the host to shut it down or just run this on the node itself.
sudo service ceph stop osd.$osd
ceph osd crush remove osd.$osd
ceph auth del osd.$osd
ceph osd rm $osd

# Now remove mount
set +e
sudo umount /var/lib/ceph/osd/ceph-$osd
sudo rm -rf /var/lib/ceph/osd/ceph-$osd

# IMPORTANT: It's worth repeating - DO NOT just reweight to 0.0 in one call unless there
# is just a small of amount of data on the OSD!
