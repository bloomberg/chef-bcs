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
  include_recipe 'chef-bcs::firewall-start'

  # Easiest way to kill all service/rules is to replace the zone file. Make sure to NOT set lockdown
  # May can later just update the zone file instead of the cli below...
  template "/etc/firewalld/zones/public.xml" do
    source 'public.xml.erb'
  end

  include_recipe 'chef-bcs::firewall-reload'

  bash 'set-default-zone' do
    user 'root'
    code <<-EOH
      firewall-cmd --set-default-zone=#{node['chef-bcs']['security']['firewall']['zone']}
    EOH
  end

  # IMPORTANT: Make sure to include SSH rule in the rules...
  ruby_block 'force later execution' do
    block do
      if node['chef-bcs']['security']['firewall']['use'] == 'rules'
        node['chef-bcs']['security']['firewall']['rules'].each do | rule |
          allow = false
          rule['roles'].each do | role |
            if node.tags.include? role
              allow = true
            end
          end

          if allow
            cmd = "firewall-cmd --zone=#{rule['zone']} "
            if rule['permanent']
              cmd += "--permanent "
            end
            rule['rules'].each do | item_rule |
              if rule['type'] == 'rich-rule'
                cmd_tmp = cmd + "--add-rich-rule=\"#{item_rule}\""
              elsif rule['type'] == 'service'
                cmd_tmp = cmd + "--add-service='#{item_rule}'"
              else
                cmd_tmp = cmd + "#{item_rule}"
              end
              cmd_output = shell_out(cmd_tmp)
              puts cmd_tmp
              puts cmd_output.stdout
            end
            # Force it
            shell_out("sudo firewall-cmd --reload")
          end
        end
      else
        include_recipe 'chef-bcs::firewall-rules-interfaces'
      end
    end
  end

  include_recipe 'chef-bcs::firewall-reload'
end
