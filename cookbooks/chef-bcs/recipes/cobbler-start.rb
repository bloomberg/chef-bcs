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
  service 'httpd' do
    action [:enable, :start]
  end
  service 'dnsmasq' do
    action [:enable, :start]
  end
  # Normally tftp will start with xinetd.
  execute 'xinetd-enable' do
    command 'sudo systemctl enable xinetd'
  end
  execute 'xinetd-start' do
    command 'sudo systemctl start xinetd'
  end
  # xinetd - tftp is managed by it but there can be an issue on some systemd systems so try to start it again.
  # NOTE: tftp.socket gets enabled on some systems but tftp.service does not thus on reboot tftp may not start. If
  # that's the case then a manual start is required or another 'custom' tftp.service in /etc/systemd/service
  service 'tftp-start' do
    service_name 'tftp'
    action [:start]
    not_if "pgrep tftp"
  end
  service 'tftp-enable' do
    service_name 'tftp'
    action [:enable]
  end
  service 'cobblerd' do
    action [:enable, :start]
  end
end

# No need to get_loaders or do signature update
