#!/bin/bash
#
# Copyright 2016, Bloomberg Finance L.P.
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

# NOTE: These helper functions need to reside on targeted node to be of any value.

# Pass in list from get_count_of_network_interfaces. Value must be passed as follows:
# var=$(get_network_interfaces)
# get_count_of_network_interfaces "$var"    <-- $var should be any variable you want but enclose with ""
function get_count_of_network_interfaces {
    net_list=(`echo $1`)
    echo ${#net_list[@]}
}

# Retrieve a list of network interfaces less the loopback
function get_network_interfaces {
    local ipfaces=($(ip a | awk '!/lo/ {print $2}' | egrep ":$" | cut -d ':' -f 1))
    echo ${ipfaces[@]}
}

# Just a rough guess for PCI NICs
function are_interfaces_consistent {
    local file_find=$(find /etc -regextype sed -regex ".*/ifcfg-enp[0-9]s[0-9]")
    if [[ `echo ${#file_find}` -gt 0 ]]; then
        echo 1
    else
        echo 0
    fi
}

function is_network_manager_running {
    local nm=$(ps aux | pgrep [N]etworkManager)
    if [[ `echo ${#nm}` -gt 0 ]]; then
        echo 1
    else
        echo 0
    fi
}

function get_network_physical_interface {
    # Can do local var here because $? will not work correctly
    dev_name=$(biosdevname -i $1)
    local rc=$(echo $?)

    if [[ $rc -eq 4 ]]; then
        dev_name="vm_interface"
    elif [[ $rc -ne 0 ]]; then
        dev_name="${rc}"
    fi
    echo $dev_name
}
