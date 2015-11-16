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

# Exit immediately if anything goes wrong, instead of making things worse.
set -e

# Pass in 2 parameters: $1 - Array, $2 element to be removed
function remove_array_element {
    local dummy=$2
    arr=(`echo $1`)
    val=$1
    # Remove the element from array list
    delete=($dummy)
    # not valid at the moment...
    export val=("${$arr[@]/$delete}")
}
