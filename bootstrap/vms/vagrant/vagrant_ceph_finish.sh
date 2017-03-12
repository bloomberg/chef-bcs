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

source vagrant_base.sh

# IMPORTANT: DO NOT attempt to put the run_list all together!!! If that happens we then need to create checks, wait
# and quorum checks!

for vm in ${ceph_vms[@]}; do
  do_on_node $vm "sudo chef-client $CHEF_CLIENT_DEBUG -o 'recipe[ceph-chef::finish]'"

  # NB: The command is used for any possible development where librados needs to be linked into projects.
  # No real need to call this in a production environment since any custom built Ceph related apps will have
  # already been built (maybe :))
  do_on_node $vm "sudo chef-client $CHEF_CLIENT_DEBUG -o 'recipe[chef-bcs::ceph-finish]'"
done
