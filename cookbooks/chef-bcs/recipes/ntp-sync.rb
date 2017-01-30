#
# Author: Chris Jones <cjones303@bloomberg.net>
# Cookbook: ceph
# Recipe: ntp-sync
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

# This recipe installs and start an NTP server for time syncing the nodes


include_recipe 'chef-bcs::ntp-stop'

# NOTE: May want to change to ntp servers in environment file...
service_type = node['chef-bcs']['init_style']

execute 'NTP resync' do
  command "ntpdate -u #{node['chef-bcs']['ntp']['servers'].first}"
  not_if "which ntp" if service_type == 'upstart'
  not_if "which ntpd" if service_type != 'updstart'
end

include_recipe 'chef-bcs::ntp-start'
