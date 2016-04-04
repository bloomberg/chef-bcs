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

template '/tmp/crush-map-additions.txt' do
    source 'ceph-crush.erb'
    owner 'root'
    mode 00644
end

# NOTE: The 'hdd' below is one of the rules.
bash "ceph-update-crushmap" do
    code <<-EOH
        ceph osd getcrushmap -o /tmp/crush-map
        crushtool -d /tmp/crush-map -o /tmp/crush-map.txt

        grep hdd /tmp/crush-map.txt
        if [[ $? -ne 0 ]]; then
          cat /tmp/crush-map-additions.txt >> /tmp/crush-map.txt
          crushtool -c /tmp/crush-map.txt -o /tmp/crush-map-new
          ceph osd setcrushmap -i /tmp/crush-map-new
        fi
    EOH
end
