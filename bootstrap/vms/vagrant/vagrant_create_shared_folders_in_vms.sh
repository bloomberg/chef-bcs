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

set -e
source vagrant_base.sh

CEPH_CHEF_FILES=ceph-files
CEPH_CHEF_REPO=ceph-host

echo "Setting up shared folders..."

# Check for VirtualBoxGuestAddon. If it's not there then rebuild it's kernel or shared folders will not work!
for vm in ${CEPH_CHEF_HOSTS[@]}; do
    echo "Verifying VirtualBoxGuestAdditions are still valid on $vm..."
    do_on_node $vm "./vbox_check_guestaddons.sh"
done

for vm in ${CEPH_CHEF_HOSTS[@]}; do
    echo "Creating directories to be mounted on $vm"
    # Directories may already be there so keep going instead of erroring out...
    set +e
    do_on_node $vm "sudo mkdir /$CEPH_CHEF_FILES 2>/dev/null"
    do_on_node $vm "sudo mkdir /$CEPH_CHEF_REPO 2>/dev/null"

    echo "Creating shared folders in $vm"
    add_shared_folder_to_vm $vm $CEPH_CHEF_FILES $BOOTSTRAP_CACHE_DIR
    add_shared_folder_to_vm $vm $CEPH_CHEF_REPO $REPO_ROOT
    set -e

    echo "Mouting shared folders in $vm"
    do_on_node $vm "sudo mount -t vboxsf -o umask=0022,gid=\$(id -u vagrant),uid=\$(id -u vagrant) $CEPH_CHEF_FILES /$CEPH_CHEF_FILES"
    do_on_node $vm "sudo mount -t vboxsf -o umask=0022,gid=\$(id -u vagrant),uid=\$(id -u vagrant) $CEPH_CHEF_REPO /$CEPH_CHEF_REPO"
done
