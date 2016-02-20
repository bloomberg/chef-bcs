#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
# Recipe:: default
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

# Recipe sets up basic network settings such as MTU

execute 'network-public' do
  command lazy { "ip link set dev #{node['chef-bcs']['network']['public']['interface']} mtu #{node['chef-bcs']['network']['public']['mtu']}" }
end

execute 'network-cluster' do
  command lazy { "ip link set dev #{node['chef-bcs']['network']['cluster']['interface']} mtu #{node['chef-bcs']['network']['cluster']['mtu']}" }
end
