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
# Shared folder function - TO BE executed on VM only!
`lsmod | grep vboxsf`
vbox_sf=$?

echo "Checking guest - $vbox_sf"
# If exit code == 1 then rebuild VBoxGuestAdditions kernel
if [[ $vbox_sf -eq 1 ]]; then
    echo "Fixing guest addons..."
    sudo yum -y install kernel-devel-`uname -r`
    vba=$(sudo find /opt -name vboxadd | grep init)
    sudo $vba setup
    #sudo /opt/VBoxGuestAdditions-`lsmod | grep -io vboxguest | xargs modinfo | grep -iw version | awk '{print $2}'`/init/vboxadd setup
    # sudo /etc/init.d/vboxadd setup
fi
