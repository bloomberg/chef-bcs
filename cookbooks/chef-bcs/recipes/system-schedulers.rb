#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
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

# Add the scheduler options
if node['chef-bcs']['system']['scheduler']['device']['enable']
    node['chef-bcs']['system']['scheduler']['device']['devices'].each_with_index do |dev, _index|
      execute 'scheduler-updates-#{index}' do
        command "echo #{node['chef-bcs']['system']['scheduler']['device']['type']} > /sys/block/#{dev}/queue/scheduler"
        only_if "test -d /sys/block/#{dev}"
      end
    end
end

# Substitute the OSD number for 0 below to check to check for 'non-besteffort' scheduler
# sudo iotop --batch --iter 1 | grep 'ceph-osd -i 0' | grep -v be/4

# Tuning tests...
# sysctl -w net.core.rmem_max=67108864 net.core.wmem_max=67108864 net.core.rmem_default=33554432 net.core.wmem_default=33554432 net.ipv4.tcp_rmem="16777216 33554432 67108864" net.ipv4.tcp_wmem="16777216 33554432 67108864"  net.core.optmem_max=33554432

# Original
# sysctl -w net.core.rmem_max=212992 net.core.wmem_max=212992 net.core.rmem_default=212992 net.core.wmem_default=212992 net.ipv4.tcp_rmem="4096 87380 6291456" net.ipv4.tcp_wmem="4096 16384 4194304" net.core.optmem_max=20480

# Perf record to test tc_malloc impact and tcp buffer change above
# sudo perf record -F 99 -ag -- sleep 60
# sudo perf report    <-- Do this after the above command completes
