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

# NOTE: May want to move mount and import to install later...

bash 'import-distro-distribution-cobbler' do
  user 'root'
  code <<-EOH
      mount -o loop /tmp/#{node['chef-bcs']['cobbler']['os']['distro']} /mnt
      cobbler import --name=#{node['chef-bcs']['cobbler']['os']['name']} --path=/mnt --breed=#{node['chef-bcs']['cobbler']['os']['breed']} --arch=#{node['chef-bcs']['cobbler']['os']['arch']}
      umount /mnt
  EOH
  not_if "cobbler distro list | grep #{node['chef-bcs']['cobbler']['os']['name']}"
  only_if "test -f /tmp/#{node['chef-bcs']['cobbler']['os']['distro']}"
end

# NOTE: By default, cobbler import above will create a profile with the name of the import + arch
# Distro was added so no need to edit it.
# Rename the profile to the FIRST profile in the data.
# There MUST be 2 profiles in the data or this will fail
bash 'profile-update-cobbler' do
  user 'root'
  code <<-EOH
    cobbler profile edit --name=#{node['chef-bcs']['cobbler']['os']['name']}-#{node['chef-bcs']['cobbler']['os']['arch']} --kickstart=/var/lib/cobbler/kickstarts/#{node['chef-bcs']['cobbler']['kickstart']['file']["#{node['chef-bcs']['cobbler']['profiles'][0]['file_type']}"]} --kopts="interface=auto"
    cobbler profile rename --name=#{node['chef-bcs']['cobbler']['os']['name']}-#{node['chef-bcs']['cobbler']['os']['arch']} --newname=#{node['chef-bcs']['cobbler']['profiles'][0]['name']}
    cobbler profile edit --name=#{node['chef-bcs']['cobbler']['profiles'][0]['name']} --comment="#{node['chef-bcs']['cobbler']['profiles'][0]['comment']}" --name-servers="#{node['chef-bcs']['dns']['servers'].join(' ')}"
    cobbler profile copy --name=#{node['chef-bcs']['cobbler']['profiles'][0]['name']} --newname=#{node['chef-bcs']['cobbler']['profiles'][1]['name']}
    cobbler profile edit --name=#{node['chef-bcs']['cobbler']['profiles'][1]['name']} --kickstart=/var/lib/cobbler/kickstarts/#{node['chef-bcs']['cobbler']['kickstart']['file']["#{node['chef-bcs']['cobbler']['profiles'][1]['file_type']}"]}
  EOH
  only_if "cobbler profile list"
  only_if "test -f /tmp/#{node['chef-bcs']['cobbler']['os']['distro']}"
end

# Update the Red Hat Satellite/Capsule/RHN info
if node['chef-bcs']['cobbler']['os']['breed'] == 'redhat' && node['chef-bcs']['cobbler']['redhat']['management']['type'] == 'on'
  bash 'cobbler-rhel-mgt' do
    user 'root'
    code <<-EOH
      cobbler profile edit --name=#{node['chef-bcs']['cobbler']['profiles'][0]['name']} --redhat-management-key=#{node['chef-bcs']['cobbler']['redhat']['management']['key']} --redhat-management-server=#{node['chef-bcs']['cobbler']['redhat']['management']['server']}
      cobbler profile edit --name=#{node['chef-bcs']['cobbler']['profiles'][1]['name']} --redhat-management-key=#{node['chef-bcs']['cobbler']['redhat']['management']['key']} --redhat-management-server=#{node['chef-bcs']['cobbler']['redhat']['management']['server']}
    EOH
    only_if "test -f /tmp/#{node['chef-bcs']['cobbler']['os']['distro']}"
  end
end

# Set up a default system - you will need to add the information via cobbler system edit on the cli to match your environment
# Also, do cobbler system add for every ceph node with mac, IP, etc OR modify the json data used by cobbler and then restart cobbler
node['chef-bcs']['cobbler']['systems'].each do | system |
  bash "add-to-cobbler" do
    user 'root'
    code <<-EOH
      cobbler system add --name=#{system['name']} --profile=#{system['profile']} --static=true --interface=#{system['network']['public']['interface']} --ip-address=#{system['network']['public']['ip']} --netmask=#{system['network']['public']['netmask']} --if-gateway=#{system['network']['public']['gateway']} --hostname=#{system['name']} --mtu=#{system['network']['public']['mtu']}
      cobbler system edit --name=#{system['name']} --static=true --interface=#{system['network']['cluster']['interface']} --ip-address=#{system['network']['cluster']['ip']} --netmask=#{system['network']['cluster']['netmask']} --if-gateway=#{system['network']['cluster']['gateway']} --mtu=#{system['network']['cluster']['mtu']}
    EOH
    not_if "cobbler system list | grep #{system['name']}"
    only_if "test -f /tmp/#{node['chef-bcs']['cobbler']['os']['distro']}"
  end
end

# Cobbler will create the base pxe boot files needed. Every time you modify profile/system/distro you will need to do a cobbler sync
execute 'cobbler-sync' do
  command lazy{ "cobbler sync" }
  only_if "test -f /tmp/#{node['chef-bcs']['cobbler']['os']['distro']}"
end
