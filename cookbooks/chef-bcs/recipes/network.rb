#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
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
# NOTE: If using VirtualBox then keep the mtu at 1500. There seems to be odd behavior on the cluster adapter if set to 9000.
# This does not apply to real nics.

execute 'network-public' do
  command lazy { "ip link set dev #{node['chef-bcs']['network']['public']['interface']} mtu #{node['chef-bcs']['network']['public']['mtu']}" }
  not_if "ip link show dev #{node['chef-bcs']['network']['public']['interface']} | grep 'mtu #{node['chef-bcs']['network']['public']['mtu']}'"
end

execute 'network-cluster' do
  command lazy { "ip link set dev #{node['chef-bcs']['network']['cluster']['interface']} mtu #{node['chef-bcs']['network']['cluster']['mtu']}" }
  not_if "ip link show dev #{node['chef-bcs']['network']['cluster']['interface']} | grep 'mtu #{node['chef-bcs']['network']['cluster']['mtu']}'"
end

# ADC nodes are the only ones that allow bonding
=begin
if !node['chef-bcs']['adc']['bond']['enable']
  node['chef-bcs']['adc']['bond']['interfaces'].each do | interface |
    template "/etc/sysconfig/network-scripts/ifcfg-#{interface}" do
      source 'ifcfg-nic.erb'
      variables lazy {
        {
          :interface => interface,
          :ip_addr => get_ip(interface),
          :netmask => get_netmask(interface),
          :gateway => get_gateway(interface)
        }
      }
    end
  end

  service 'network' do
    provider Chef::Provider::Service::Redhat
    action [:enable, :restart]
    supports :restart => true, :status => true
    subscribes :restart, "template[/etc/sysconfig/network-scripts/ifcfg-#{node['chef-bcs']['adc']['bond']['interfaces'][0]}]"
  end

end
=end
