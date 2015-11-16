#
# Author: Chris Jones <cjones303@bloomberg.net>
# Cookbook: ceph
# Recipe: ntp-start
#
# Copyright 2015, Bloomberg Finance L.P.
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

# This recipe starts an NTP server for time syncing the nodes

service_type = node['chef-bcs']['init_style']

if service_type == 'upstart'
  service 'ntp' do
    provider Chef::Provider::Service::Upstart
    supports :status => true
    action [:enable, :start]
    # opposite
    not_if "which ntp"
  end
else
  service 'ntpd' do
    provider Chef::Provider::Service::Redhat
    supports :status => true
    action [:enable, :start]
    # opposite
    not_if "which ntpd"
  end
end
