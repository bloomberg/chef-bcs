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

# IMPORTANT: ALL nodes have a public network (no dedicated management network) including the bootstrap node in this
# example. You can change this to fit your needs.
# firewall_rule 'public' do
#   interface "#{node['chef-bcs']['network']['public']['interface']}"
#   permanent true
# end

# firewall_rule 'cluster' do
#   interface "#{node['chef-bcs']['network']['cluster']['interface']}"
#   command  :allow
# end

# Set the firewall rules for whatever tags are associated for the given node.

# NOTE: Protocol numbers can be found at http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
# tcp - 6, udp - 17

# If the firewall is enabled
if node['chef-bcs']['security']['firewall']['enable']
  bash 'set-default-zone' do
    user 'root'
    code <<-EOH
      firewall-cmd --set-default-zone=#{node['chef-bcs']['security']['firewall']['zone']}
    EOH
  end

  # Remove all services and rules. If we add more options then remove them too before adding new ones
  bash 'remove-firewalld-rules' do
    user 'root'
    code <<-EOH
      for rule in $(firewall-cmd --zone=#{node['chef-bcs']['security']['firewall']['zone']} --list-rich-rules); do
        firewall-cmd --zone=#{node['chef-bcs']['security']['firewall']['zone']} --remove-rich-rule="$rule"
      done
    EOH
  end

  bash 'remove-firewalld-services' do
    user 'root'
    code <<-EOH
      for service in $(firewall-cmd --zone=#{node['chef-bcs']['security']['firewall']['zone']} --list-services); do
        firewall-cmd --zone=#{node['chef-bcs']['security']['firewall']['zone']} --remove-service="$service"
      done
    EOH
  end

  # IMPORTANT: Make sure to include SSH rule in the rules...
  if node['chef-bcs']['security']['firewall']['use'] == 'rules'
    node['chef-bcs']['security']['firewall']['rules'].each do | rule |
      cmd = "firewall-cmd --zone=#{rule['zone']} "
      if rule['permanent']
        cmd += "--permanent "
      end
      rule['rules'].each do | item_rule |
        if rule['type'] == 'rich-rule'
          cmd_tmp = cmd + "#{item_rule}"
        else
          # assumes service
          cmd_tmp = cmd + "--add-service='#{item_rule}'"
        end
        cmd_output = shell_out(cmd_tmp)
        puts cmd_tmp + " -- " + cmd_output
      end
    end
  else
    include_recipe 'chef-bcs::firewall-rules-interfaces'
  end

  bash 'firewall-reload' do
    user 'root'
    code <<-EOH
      firewall-cmd --reload
    EOH
  end
end
