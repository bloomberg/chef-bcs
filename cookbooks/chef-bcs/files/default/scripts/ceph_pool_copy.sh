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

source /ceph-host/bootstrap/data/environment/production/scripts/base.sh

new_pool=$1
old_pool=$2
# Set a default here...
pg_num=$3

if [[ -z $new_pool || -z $old_pool ]]; then
  echo 'Must have valid new_pool and old_pool names.'
  exit 1
fi

if [[ $pg_num -lt 1 ]]; then
  echo 'Make sure the pg_num value is greater than 0 but really it should be a valid number.'
  exit 1
fi

ceph osd pool create $new_pool $pg_num
rados cppool $old_pool $new_pool

# May want to move delete and rename to another script so you can do verification in between.
ceph osd pool delete $old_pool
ceph osd pool rename $new_pool $old_pool
