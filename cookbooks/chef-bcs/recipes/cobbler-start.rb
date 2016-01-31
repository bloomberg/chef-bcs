#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
# Recipe:: ceph-mon
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

case node['platform']
when 'ubuntu'
  service 'isc-dhcp-server' do
      action [:enable, :start]
  end
  service 'cobbler' do
      action [:enable, :start]
  end
  service 'apache2' do
      action [:enable, :start]
  end
else
  service 'cobblerd' do
      action [:enable, :start]
  end
  service 'httpd' do
      action [:enable, :start]
  end
  service 'dnsmasq' do
      action [:enable, :start]
  end
  service 'xinetd' do
      action [:enable, :start]
  end
  # xinetd - tftp is managed by it but there can be an issue on some systemd systems so try to start it again.
  # NOTE: tftp.socket gets enabled on some systems but tftp.service does not thus on reboot tftp may not start. If
  # that's the case then a manual start is required or another 'custom' tftp.service in /etc/systemd/service 
  service 'tftp' do
      action [:enable, :start]
      not_if "pgrep tftp"
  end
end

# No need to get_loaders or do signature update
