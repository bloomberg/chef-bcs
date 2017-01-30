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

# Setup Ceph Crushmap
# NOTE: Only needs to be done on first mon node
do_on_node $CEPH_CHEF_BOOTSTRAP "$KNIFE node run_list add ${CEPH_MON_HOSTS[@]:0:1}.$BOOTSTRAP_DOMAIN 'role[ceph-crushmap]' $CHEF_KNIFE_DEBUG"
do_on_node ${CEPH_MON_HOSTS[@]:0:1} "sudo chef-client $CHEF_CLIENT_DEBUG -o 'role[ceph-crushmap]'"
