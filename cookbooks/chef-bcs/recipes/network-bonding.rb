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

# NOTE: Bonding - *IMPORTANT* - Make sure your network SWITCH is configured for bonding or you may not be able to reach
# your node. You will then have to use your IPMI (depending on platform) UI to get to the console to change things!!

# Also, bonding is *NOT* recommended as part of a default Architecture *UNLESS* you have the ports on a single card and
# you're only using one interface. For example, RGW and MON nodes only use the "public" interface but if you
# standardize on nics which most people do then you will have the "cluster" interface available and doing nothing on
# those nodes so bonding in this case is acceptable.

# It is *ALWAYS* better to have a larger interface port instead of bonding if possible because you will get better
# overall throughput.

execute 'modprobe-bond' do
  command 'modprobe --first-time bonding'
  ignore_failure true
end

# NOTE: bonding_options. Change bond-options in the given environment json file
# mode=0 (Balance Round Robin)
# mode=1 (Active backup)
# mode=2 (Balance XOR)
# mode=3 (Broadcast)
# mode=4 (802.3ad) - Aggregate which is default for bare-metal - LACP
# mode=5 (Balance TLB)
# mode=6 (Balance ALB)

# IMPORTANT: VirtualBox has known issues with bonding. So, it's best not to do the following with VirtualBox:
# 1. Set mtu higher than 1500
# 2. Set the GATEWAY in the ifcfg-bond file
# 3. Set mode=4. Instead use "mode=1 miimon=100 fail_over_mac=1" for bonding_opts

# IMPORTANT: bare-metal should be set:
# 1. Set "mode=4 miimon=100 xmit_hash_policy=layer2+3" for bonding_opts
# 2. Set GATEWAY to proper gateway of TOR or router depending on how your network is setup
# 3. Set mtu to 9000 if possible. Significant performance increase. IMPORTANT: auto-adjust (discovery) of mtu should be enabled on servers/routers or lower mtu clients will FAIL!

# You can check what the bond looks like with:
# 1. ip a
# 2. cat /proc/net/bonding/bond0
# 3. modinfo bonding
# 4. netstat -rn  - IF you see a zeroconfig '169.254.0.0' no need to be concerned (http://www.zeroconf.org/). However, if you wish to remove it then add the following to the /etc/sysconfig/network file: NOZEROCONF=no

# NOTE: IMPORTANT: The get_bond functions referenced below WILL CHANGE the result of the json file based on VirtualBox!!!!
# NOTE: Could turn 'bond' into 'bonds': [{...}] and then loop the template below to have multiple bonds.
# NOTE: MAKE SURE to change your TOR (Switch) so that it supports whatever mode you set (see above) - bare-metal only

bond = false
bond_interfaces = []
bond_name = ''
bond_mtu = 9000

if is_adc_node && node['chef-bcs']['adc']['bond']['enable']
  bond = true
  bond_interfaces = node['chef-bcs']['adc']['bond']['interfaces']
  bond_name = node['chef-bcs']['adc']['bond']['name']
  bond_mtu = node['chef-bcs']['adc']['bond']['mtu']
end

if is_radosgw_node && node['chef-bcs']['ceph']['radosgw']['bond']['enable']
  bond = true
  bond_interfaces = node['chef-bcs']['ceph']['radosgw']['bond']['interfaces']
  bond_name = node['chef-bcs']['radosgw']['bond']['name']
  bond_mtu = node['chef-bcs']['radosgw']['bond']['mtu']
end

if is_mon_node && node['chef-bcs']['ceph']['mon']['bond']['enable']
  bond = true
  bond_interfaces = node['chef-bcs']['ceph']['mon']['bond']['interfaces']
  bond_name = node['chef-bcs']['mon']['bond']['name']
  bond_mtu = node['chef-bcs']['mon']['bond']['mtu']
end

if bond
  template "/etc/sysconfig/network-scripts/ifcfg-bond0" do
    source 'ifcfg-bond0.erb'
    variables lazy {
      {
        :ip_addr => get_bond_ip,
        :net_mask => get_bond_netmask,
        :gateway => get_bond_gateway,
        :bond_name => bond_name,
        :bond_options => bond_options,
        :mtu => bond_mtu
      }
    }
  end

  bond_interfaces.each do | interface |
    template "/etc/sysconfig/network-scripts/ifcfg-#{interface}" do
      source 'ifcfg-slave.erb'
      variables lazy {
        {
          :interface => interface,
          :bond_name => bond_name
        }
      }
    end
  end

  service 'network' do
    action [:enable, :restart]
    supports :restart => true, :status => true
    subscribes :restart, "template[/etc/sysconfig/network-scripts/ifcfg-#{bond_name}]"
  end

  execute 'bond-mtu' do
    command lazy { "ip link set dev #{bond_name} mtu #{bond_mtu}" }
    not_if "ip link show dev #{bond_name} | grep 'mtu #{bond_mtu}'"
  end
end
