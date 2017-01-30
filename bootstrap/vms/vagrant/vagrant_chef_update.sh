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

# Allow you to update the chef-server (bootstrap node) with changes you have made.

source vagrant_base.sh

do_on_node $CEPH_CHEF_BOOTSTRAP "cd \$HOME && rsync -a /ceph-host/* ./chef-bcs"

do_on_node $CEPH_CHEF_BOOTSTRAP "$KNIFE cookbook upload ceph-chef -a"
do_on_node $CEPH_CHEF_BOOTSTRAP "cd \$HOME/chef-bcs/roles && $KNIFE role from file *.json"
do_on_node $CEPH_CHEF_BOOTSTRAP "cd \$HOME/chef-bcs/environments && $KNIFE environment from file $BOOTSTRAP_CHEF_ENV.json"
