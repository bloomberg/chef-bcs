#!/bin/bash
#
# Author:: Chris Jones <cjones303@bloomberg.net>
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

ceph osd getcrushmap -o /tmp/tmp.out
crushtool -d /tmp/tmp.out -o /tmp/tmp.txt
vim /tmp/tmp.txt

# NOTE: If your crushmap has the wrong number of rules then most likely the crushmap is incorrect and the PGs will stay in a state of confusion.
# If your crushmap hierarchy design does *NOT* include your pools as rules but when you view your crushmap it shows a rule that matches your pools
# *AND* your PGs are confused (stale+inactive...) then your process of adding/moving the OSD and/or setting your crush_ruleset for your pool may
# be incorrect. Also note, you can have rules for pools if that fits your design. Experiment with the hierarchy before declaring something
# production ready.
