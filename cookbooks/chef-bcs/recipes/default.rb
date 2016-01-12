#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
# Recipe:: default
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

# PURPOSE:
# This recipe installs packages which are useful for debugging the stack
# and troubleshooting system issues. Packages should not be included here
# if the stack itself depends on them for its normal operation.

# The recipe also sets up security on ALL nodes AND initial Users!
# The recipe also adds the PS1 prompt change for all nodes!

# Network troubleshooting tools
package "ethtool"
package "nmap"
package "iperf"
package "curl"

# I/O troubleshooting tools
package "fio"
package "bc"
package "iotop"

# System troubleshooting tools
package "htop"
package "sysstat"
package "vim"

# RHEL version...
package "python-pip"

# Create an operations user
if node['chef-bcs']['users']
  users = node['chef-bcs']['users']
  users =  Hash[(0...users.size).zip users] unless users.is_a? Hash
  users.each do |index, user_value|
    if user_value['passwd'].empty?
      pwd = secure_password
    else
      pwd = user_value['passwd']
    end

    user user_value['name'] do
      comment user_value['comment']
      shell '/bin/bash'
      password pwd
    end

    template "/home/#{user_value['name']}/.bashrc" do
      source 'operations.bashrc.erb'
      mode 00770
    end

    # Save the pwd to use it later for reference info.
    node.normal['chef-bcs']['users'][index]['passwd'] = pwd
    node.save
  end
end

# Set initial sudoers
# NOTE: If you add the same user as is in the kickstart then it's removed from the list
if node['chef-bcs']['authorization']
  node.normal['authorization']['sudo']['include_sudoers_d'] = node['chef-bcs']['authorization']['sudo']['include_sudoers_d'] if node['chef-bcs']['authorization']['sudo']['include_sudoers_d']
  node.normal['authorization']['sudo']['passwordless'] = node['chef-bcs']['authorization']['sudo']['passwordless'] if node['chef-bcs']['authorization']['sudo']['passwordless']
  node.normal['authorization']['sudo']['users'] = node['chef-bcs']['authorization']['sudo']['users'] if node['chef-bcs']['authorization']['sudo']['users']
  node.save
  # Add more metadata if needed
end
