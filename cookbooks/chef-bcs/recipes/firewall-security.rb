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

# FirewallD is setup for rhel and iptables are used for ubuntu

# Will override the sshd_config that is present for better practices on security.
template "/etc/ssh/sshd_config" do
  source 'sshd_config.erb'
  group 'root'
  user 'root'
  mode '0600'
end

# firewall coobook...
# all defaults - enable firewall on all nodes with ssh access
# firewall 'default'

# enable platform default firewall
firewall 'default' do
  action :install
  enabled_zone :public
end

# rules
# By default there are no icmp blocks. If you want to enable icmp blocks (pings...) then add.

firewall_rule 'ssh' do
  port     22
  command  :allow
  permanent true
end

firewall_rule 'ntp' do
  command  :allow
  permanent true
end

# IMPORTANT: ALL nodes have a public network (no dedicated management network) including the bootstrap node in this
# example. You can change this to fit your needs.
firewall_rule 'public' do
  interface "#{node['chef-bcs']['network']['public']['interface']}"
  permanent true
  command  :allow
end

firewall_rule 'cluster' do
  interface "#{node['chef-bcs']['network']['cluster']['interface']}"
  permanent true
  command  :allow
end

# Force the rules etc to be saved
firewall 'default' do
  action :save
end
