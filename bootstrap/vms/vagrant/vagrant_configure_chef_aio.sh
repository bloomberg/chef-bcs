#!/bin/bash
#
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

# Exit immediately if anything goes wrong, instead of making things worse on fresh builds
set -e

#################
# NOTE: This is the Vagrant AIO (All In One) Chef configuration for Ceph script.
#################

# NOTE: vagrant_base MUST be first! Actually, everything below should be in the order shown for Object Store.
#source vagrant_base.sh

source vagrant_bootstrap_chef.sh

source vagrant_bootstrap_chef_vms.sh

source vagrant_bootstrap_chef_client.sh

source vagrant_chef_create_tags.sh

source vagrant_ceph_mon.sh

source vagrant_ceph_osd.sh

source vagrant_ceph_tunables.sh

source vagrant_ceph_pools.sh

source vagrant_ceph_rgw.sh

# source vagrant_ceph_rgw_users.sh

source vagrant_ceph_restapi.sh

source vagrant_ceph_finish.sh

echo "Completed Chef configuration!!"
