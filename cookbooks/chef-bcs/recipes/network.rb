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

if node['chef-bcs']['network']['cluster']['route']['cidr']
  gateway = get_gateway("#{node['chef-bcs']['network']['cluster']['interface']}")
  execute 'network-cluster-route' do
    command lazy { "ip route add #{node['chef-bcs']['network']['cluster']['route']['cidr']} via #{gateway} dev #{node['chef-bcs']['network']['cluster']['interface']}" }
    ignore_failure true
  end
end

# Set the cluster nic gateway to null (remove it) for routed racks or ARP may have a race condition issue
if !node['chef-bcs']['network']['cluster']['gateway_enable']
  template "/etc/sysconfig/network-scripts/ifcfg-#{node['chef-bcs']['network']['cluster']['interface']}" do
    source 'ifcfg-cluster-nic.erb'
    variables lazy {
      {
        :ip_addr => get_ip("#{node['chef-bcs']['network']['cluster']['interface']}")
        :netmask => get_netmask("#{node['chef-bcs']['network']['cluster']['interface']}")
      }
    }
  end

  template "/etc/sysconfig/network-scripts/route-#{node['chef-bcs']['network']['cluster']['interface']}" do
    source 'route-cluster.erb'
    variables lazy {
      {
        :gateway => get_gateway("#{node['chef-bcs']['network']['cluster']['interface']}")
      }
    }
  end
end

# NOTE: May want to add a recipe that configures the interfaces in non-bonding mode in the event something happens.
# Cobbler creates the interfaces initially.
