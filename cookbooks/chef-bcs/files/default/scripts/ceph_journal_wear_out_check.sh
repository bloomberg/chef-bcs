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

dev=$1

if [[ -z $dev ]]; then
  echo "Must specify a valid device."
  exit 1
fi

# Lists out the smart info for SSD journals. The main thing to look at is the 'Wearout_Indicator'. The lower it is
# the sooner is will fail.

sudo smartclt -a $dev
