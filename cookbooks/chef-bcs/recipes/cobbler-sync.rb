#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
# Recipe:: ceph-mon
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
    user "root"
    code <<-EOH
        mount -o loop /tmp/#{node['chef-bcs']['cobbler']['distro']}.iso /mnt
        cobbler import --name=#{node['chef-bcs']['cobbler']['os_name']} --path=/mnt --breed=#{node['chef-bcs']['cobbler']['breed']} --arch=#{node['chef-bcs']['cobbler']['os_arch']}
        umount /mnt
        cobbler sync
    EOH
    not_if "cobbler distro list | grep #{node['chef-bcs']['cobbler']['os_name']}"
end

bash 'import-chef-bcs-profile-cobbler' do
    user 'root'
    code <<-EOH
        cobbler profile add --name=ceph_chef_host --distro=#{node['chef-bcs']['cobbler']['os_name']}-#{node['chef-bcs']['cobbler']['os_arch']} --kickstart=/var/lib/cobbler/kickstarts/#{node['chef-bcs']['kickstart']['file']} --kopts="interface=auto"
        cobbler sync
    EOH
    not_if "cobbler profile list | grep ceph_chef_host"
end

bash 'add-system-to-cobbler' do
    user 'root'
    code <<-EOH
        cobbler system add --name=ceph_nodes --profile=ceph_chef_host
        cobbler sync
    EOH
    # not_if "cobbler system list | grep ceph_nodes"
end
