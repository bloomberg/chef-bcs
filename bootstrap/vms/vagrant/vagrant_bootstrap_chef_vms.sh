#!/bin/bash
#
# Author: Chris Jones <cjones303@bloomberg.net>
# Copyright 2015, Bloomberg Finance L.P.
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

# Reverse cloning of cloned VMs so as to make them active in a clean state (same as the point where they were cloned).

# NOTE: MUST execute from VAGRANT directory of project

source vagrant_base.sh

# This ONLY bootstraps Chef on the working vms and sets up authorization via actor maps.

for vm in ${ceph_vms[@]}; do
  # TODO: Make OS check here to do for Ubuntu or RHEL based...
  do_on_node $vm "sudo rpm -Uvh \$(find /ceph-files/ -name chef-\*rpm -not -name \*downloaded | tail -1)"

  # NOTE: If this command seems to stall then the network needs to be reset. Run ./vagrant_reset_network.sh from the
  # directory this script is located in. This will clean any network issues. Same holds true for other VMs.
  do_on_node $CEPH_CHEF_BOOTSTRAP "$KNIFE bootstrap -x vagrant -P vagrant --sudo $vm.$BOOTSTRAP_DOMAIN"
done

# augment the previously configured nodes with our newly uploaded environments and roles
for vm in ${CEPH_CHEF_HOSTS[@]}; do
  do_on_node $CEPH_CHEF_BOOTSTRAP "$KNIFE node environment set $vm.$BOOTSTRAP_DOMAIN $BOOTSTRAP_CHEF_ENV"
done

do_on_node $CEPH_CHEF_BOOTSTRAP "$KNIFE node run_list set $CEPH_CHEF_BOOTSTRAP.$BOOTSTRAP_DOMAIN 'role[ceph-bootstrap]'"

# generate actor map
do_on_node $CEPH_CHEF_BOOTSTRAP "cd \$HOME && $KNIFE actor map"
# using the actor map, set ceph-bootstrap, ceph-*-vms (if any) as admins so that they can write into the data bag
#do_on_node ceph-bootstrap "cd \$HOME && $KNIFE group add actor admins ceph-bootstrap.$BOOTSTRAP_DOMAIN"  # && $KNIFE group add actor admins cos-vm1.$BOOTSTRAP_DOMAIN"

# Add each node to the bootstrap actor map
for vm in ${CEPH_CHEF_HOSTS[@]}; do
  do_on_node $CEPH_CHEF_BOOTSTRAP "cd \$HOME && $KNIFE group add actor admins $vm.$BOOTSTRAP_DOMAIN"
done
