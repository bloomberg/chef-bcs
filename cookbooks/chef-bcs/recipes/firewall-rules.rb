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

# firewall coobook...
# all defaults - enable firewall on all nodes with ssh access
# firewall 'default'

# rules
# By default there are no icmp blocks. If you want to enable icmp blocks (pings...) then add the block here.

# NOTE: These rules should ALWAYS be present.
firewall_rule 'ssh' do
  port     22
  command  :allow
end

firewall_rule 'ntp' do
  command  :allow
end

# IMPORTANT: ALL nodes have a public network (no dedicated management network) including the bootstrap node in this
# example. You can change this to fit your needs.
firewall_rule 'public' do
  interface "#{node['chef-bcs']['network']['public']['interface']}"
  permanent true
end

firewall_rule 'cluster' do
  interface "#{node['chef-bcs']['network']['cluster']['interface']}"
  command  :allow
end

# Set the firewall rules for whatever tags are associated for the given node.

node['chef-bcs']['security']['firewall']['interfaces'].each do | interface |
  # Build port list
  ports = []
  ranges = []

  interface['ports'].each do | port |
    if node.tags.include? port['role']
      if port['open'].any?
        ports << port['open']
      end

      port['ranges'].each do | range |
        if range['start'] > 0
          start_range = range['start']
          end_range = range['end']
          ranges << (start_range..end_range)
        end
      end
    end
  end

  if ports.any?
    firewall_rule interface['name'] do
      interface "#{node['chef-bcs']['network'][interface['name']]['interface']}"
      port ports.uniq.flatten
      command :allow
    end
  end

  ranges.each do | range |
    firewall_rule interface['name'] do
      interface "#{node['chef-bcs']['network'][interface['name']]['interface']}"
      port range
      command :allow
    end
  end
end

# Force the rules etc to be saved
firewall 'default' do
  action :save
end
