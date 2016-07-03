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

# ONLY runs on bootstrap (Chef Server) node

node=$1

if [[ -z $node ]]; then
  echo 'Must pass in a valid node name.'
  exit 1
fi

# Example of deleting an attribute for normal_attrs. You can also use default_attrs and override_attrs.
# You can also use :all in place of 'name:<node name here>' below...
# knife exec -E "nodes.find(:name => 'NODE-1') { |node|  node['node_data']['source_repo'] = '/new/path/softwares/'; node.save; }"

# This will remove ALL of the OSD attributes for a given node. After this is ran you can run: sudo chef-client
# on the node to rebuild the ALL of the OSDs.

# IMPORTANT: Make sure to follow this guideline for adding the OSDs for the given *IF* the node had OSDs BEFORE
# (If the node never had OSDs before then don't use this script)
# 1. Stop Ceph on node: sudo service ceph stop
# 2. If /var/lib/ceph/osd/ceph-* are mounted (df -h) then: sudo umount /var/lib/ceph/osd/*
# 3. Run ./ceph_cleanup_wipe_out_osds_on_node.sh on the node itself (will have to be rebooted - see #4)
# 4. Attempt to remove ceph-* directories: sudo rm -rf /var/lib/ceph/osd/ceph-* (most likely it will not remove the directories because it's busy - reboot will be required)
# 5. After reboot (see #4) then try to remove directories again
# 6. Run this command on the bootstrap node where the Chef Server is located
# 7. Run sudo chef-client on the given node (this will re-create the OSDs and Journals)
# 8. May need to start Ceph again on node so check. If so then: sudo service ceph start and run sudo chef-client again (this will update the crushmap now that the OSD daemons are running again)

knife exec -E "nodes.transform('name:$node') {|n| n.normal_attrs['ceph']['osd'].delete('devices') rescue nil }"
