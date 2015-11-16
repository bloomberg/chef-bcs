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

source vagrant_base.sh

# Should ONLY run this once. It's here just in case you want to break it out and use it that way.
do_on_node ${CEPH_CHEF_HOSTS[@]:1:1} "sudo chef-client -o 'recipe[ceph-chef::radosgw_users]'"

# This is here to show that radosgw_users can be broken out if did not want it apart of the ceph-radosgw role. Just uncomment and remove from the role.
# do_on_node ${CEPH_CHEF_HOSTS[@]:1:1} "sudo chef-client -o 'recipe[ceph-chef::radosgw_users]'"
