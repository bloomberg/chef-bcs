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

# PURPOSE:
# This recipe installs packages which are useful for debugging the stack
# and troubleshooting system issues. Packages should not be included here
# if the stack itself depends on them for its normal operation.

# The recipe also sets up security on ALL nodes AND initial Users!
# The recipe also adds the PS1 prompt change for all nodes!

include_recipe 'chef-bcs::ceph-conf'

# Network troubleshooting tools
package 'ethtool'
package 'nmap'
package 'iperf'
package 'curl'
package 'bmon'
package 'socat'
package 'iftop'
# package 'conntrack'
package 'tmux'
package 'fping'
# Used to help find sensor issues on nodes if BMC doesn't show much
package 'lm_sensors'

# I/O troubleshooting tools
package 'fio'
package 'bc'
package 'iotop'
package 'atop'

# System troubleshooting tools
package 'htop'
package 'sysstat'
package 'vim'
package 'patch'
package 'lshw'
package 'sg3_utils'
package 'sshpass'

# JSON parse
# package 'jp'

if node['chef-bcs']['init_style'] == 'upstart'
  package 'python-dev'
  package 'build-essential'
else
  # Yum versionlock - Check the yum-versionlock recipe for details...
  package 'yum-versionlock'
  package 'kexec-tools'
end

package 'python-pip' do
  :upgrade
end
package 'python-boto' do
  :upgrade
end

# Copy the scripts to the nodes
remote_directory '/etc/ceph/scripts' do
  source 'scripts'
  action :create
  owner node['chef-bcs']['chef']['owner']
  mode 0755
end

execute 'set-scripts-perm' do
  command "sudo chmod +x /etc/ceph/scripts/*.sh"
end

# Create user(s) if not already existing
node['chef-bcs']['cobbler']['kickstart']['users'].each do | user_value |
  user user_value['name'] do
    comment user_value['comment']
    shell user_value['shell']
    password user_value['passwd']
    ignore_failure true
  end
end

template "/etc/profile.d/chef-bcs.sh" do
  source 'chef-bcs.sh.erb'
  ignore_failure true
end

# Add the scary MOTD to let people know it's production!!
template '/etc/motd' do
  source 'motd.tail.erb'
  mode 00644
end

# Set ntp servers
node.default['ntp']['servers'] = node['chef-bcs']['ntp']['servers']
