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

package 'keepalived' do
  action :upgrade
end

# Installs killall
package 'psmisc'

# Set the config
# NOTE: If the virtual_router_id is
template "/etc/keepalived/keepalived.conf" do
  source 'keepalived.conf.erb'
  variables lazy {
    {
      :adc_nodes => adc_nodes,
      :server => get_keepalived_server
    }
  }
end

# All for binding additional IPs not found in ifcfg files.
# Sets ipv4 forwarding rule
template "/etc/sysctl.d/99-sysctl.conf" do
  source '99-sysctl.conf.erb'
end

execute 'update-sysctl' do
  command 'sysctl -p'
end

if node['chef-bcs']['init_style'] == 'upstart'
else
  # Broke out the service resources for better idempotency.
  service 'keepalived' do
    action [:enable]
    only_if "sudo systemctl status keepalived | grep disabled"
  end

  service 'keepalived' do
    action [:start]
    supports :restart => true, :status => true
    subscribes :restart, "template[/etc/keepalived/keepalived.conf]"
  end
end
