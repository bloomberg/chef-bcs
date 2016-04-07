#
# Author: Chris Jones <cjones303@bloomberg.net>
# Cookbook: chef-bcs
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

include_recipe 'chef-bcs::ceph-conf'

# This recipe must run after the ceph-chef::osd recipe to set the crush map settings.

# Remove rbd pool (only using rgw)
if node['ceph']['osd']['crush']['update']
  bash "ceph-remove-crushmap-defaults" do
      code <<-EOH
          ceph osd getcrushmap -o /tmp/crush-map
          crushtool -d /tmp/crush-map -o /tmp/crush-map.txt

          rados lspools | grep rbd
          if [[ $? -eq 0 ]]; then
            ceph osd pool delete rbd rbd --yes-i-really-really-mean-it
          fi

          grep default /tmp/crush-map.txt
          if [[ $? -ne 0 ]]; then
            ceph osd crush rule rm replicated_ruleset
            ceph osd crush remove default
          fi
      EOH
  end
end
