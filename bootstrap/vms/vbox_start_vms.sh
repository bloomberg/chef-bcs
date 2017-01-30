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
set -e

export REPO_ROOT=$(git rev-parse --show-toplevel)

source $REPO_ROOT/bootstrap/vms/vbox_functions.sh
source $REPO_ROOT/bootstrap/vms/ceph_chef_hosts.env
source $REPO_ROOT/bootstrap/vms/ceph_chef_adapters.env
source $REPO_ROOT/bootstrap/vms/ceph_chef_bootstrap.env

start_vms

if [[ $BOOTSTRAP_TYPE == "vagrant" ]]; then
  cd $REPO_ROOT/bootstrap/vms/vagrant

  source $REPO_ROOT/bootstrap/vms/vagrant/vagrant_create_shared_folders_in_vms.sh
  source $REPO_ROOT/bootstrap/vms/vagrant/vagrant_mount_vms.sh
  source $REPO_ROOT/bootstrap/vms/vagrant/vagrant_reset_network.sh
else
  source $REPO_ROOT/bootstrap/vms/vbox_reset_network.sh
fi
