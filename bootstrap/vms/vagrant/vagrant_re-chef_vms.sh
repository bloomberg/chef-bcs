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

#source ../base_environment.sh

#source $REPO_ROOT/bootstrap/vms/ceph_chef_bootstrap.env
#source $REPO_ROOT/bootstrap/vms/ceph_chef_hosts.env
#source $REPO_ROOT/bootstrap/vms/ceph_chef_adapters.env
#source $REPO_ROOT/bootstrap/vms/vbox_functions.sh

#do_on_node() {
#  echo
#  echo "Issuing command: vagrant ssh $1 -c ${2}"
#  echo "----------------------------------------------------------------------------------------"
#  NODE=$1
#  shift
#  COMMAND="${*}"
#  vagrant ssh $NODE -c "$COMMAND"
#}

#cd $REPO_ROOT/bootstrap/vms/vagrant

# use Chef Server embedded knife instead of the one in /usr/bin
#KNIFE=/opt/opscode/embedded/bin/knife

#delete=($CEPH_CHEF_BOOTSTRAP)
#ceph_vms=("${CEPH_CHEF_HOSTS[@]/$delete}")

for vm in ${ceph_vms[@]}; do
  do_on_node $vm "sudo chef-client"
done
