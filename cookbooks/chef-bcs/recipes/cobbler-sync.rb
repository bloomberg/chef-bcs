#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
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

# NOTE: May want to move mount and import to install later...

bash 'import-distro-distribution-cobbler' do
    user 'root'
    code <<-EOH
        mount -o loop /tmp/#{node['chef-bcs']['cobbler']['distro']} /mnt
        cobbler import --name=#{node['chef-bcs']['cobbler']['os_name']} --path=/mnt --breed=#{node['chef-bcs']['cobbler']['breed']} --arch=#{node['chef-bcs']['cobbler']['os_arch']}
        umount /mnt
    EOH
    not_if "cobbler distro list | grep #{node['chef-bcs']['cobbler']['os_name']}"
    only_if "test -f /tmp/#{node['chef-bcs']['cobbler']['distro']}"
end

# NOTE: By default, cobbler import above will create a profile with the name of the import + arch
bash 'profile-edit-cobbler' do
    user 'root'
    code <<-EOH
        cobbler profile edit --name=#{node['chef-bcs']['cobbler']['os_name']}-#{node['chef-bcs']['cobbler']['os_arch']} --kickstart=/var/lib/cobbler/kickstarts/#{node['chef-bcs']['cobbler']['kickstart']['file']} --kopts="interface=auto"
    EOH
    only_if "cobbler profile list | grep #{node['chef-bcs']['cobbler']['os_name']}"
    only_if "test -f /tmp/#{node['chef-bcs']['cobbler']['distro']}"
end

# Set up a default system - you will need to add the information via cobbler system edit on the cli to match your environment
# Also, do cobbler system add for every ceph node with mac, IP, etc OR modify the json data used by cobber and then restart cobbler
bash 'add-system-to-cobbler' do
    user 'root'
    code <<-EOH
        cobbler system add --name=ceph_node --profile=#{node['chef-bcs']['cobbler']['os_name']}-#{node['chef-bcs']['cobbler']['os_arch']}
    EOH
    not_if "cobbler system list | grep ceph_node"
    only_if "test -f /tmp/#{node['chef-bcs']['cobbler']['distro']}"
end

# Cobbler will create the base pxe boot files needed. Every time you modify profile/system/distro you will need to do a cobbler sync
execute 'cobbler-sync' do
  command lazy{ "cobbler sync" }
  only_if "test -f /tmp/#{node['chef-bcs']['cobbler']['distro']}"
end
