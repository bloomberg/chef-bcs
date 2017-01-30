#
# Author: Chris Jones <cjones303@bloomberg.net>
# Cookbook: chef-bcs
#
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

include_recipe 'chef-bcs::ceph-conf'

# This recipe must run after the ceph-chef::osd recipe to set the crush map settings.

if node['ceph']['osd']['crush']['update']
  template '/tmp/crush-map-new.txt' do
      source 'ceph-crush.erb'
      owner 'root'
      mode 00644
  end

  # Removes the default including the default rbd pool
  # include_recipe 'chef-bcs::crushmap-remove-defaults'

  # NOTE: The 'hdd' below is one of the rules.
  # This will override the default crushmap which is for replication instead of erasure-code. Also, added updated straw alg.
  # Removed the following two lines for testing new crushmap file.
  # ceph osd getcrushmap -o /tmp/crush-map
  # crushtool -d /tmp/crush-map -o /tmp/crush-map.txt
  bash "ceph-update-crushmap" do
      code <<-EOH
          ceph osd getcrushmap -o /tmp/crush-map
          crushtool -d /tmp/crush-map -o /tmp/crush-map.txt
          grep hdd /tmp/crush-map.txt
          if [[ $? -ne 0 ]]; then
            crushtool -c /tmp/crush-map-new.txt -o /tmp/crush-map-new
            ceph osd setcrushmap -i /tmp/crush-map-new
          fi
      EOH
  end
end
