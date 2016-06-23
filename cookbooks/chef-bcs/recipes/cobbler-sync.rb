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

include_recipe 'chef-bcs::ceph-conf'

# NOTE: May want to move mount and import to install later...
# cobbler distro edit --name=#{node['chef-bcs']['cobbler']['os']['name']}-#{node['chef-bcs']['cobbler']['os']['arch']} --kopts="ksdevice= inst.repo=http://#{node['chef-bcs']['cobbler']['server']}/cblr/ks_mirror/#{node['chef-bcs']['cobbler']['os']['name']}"

bash 'import-distro-distribution-cobbler' do
  user 'root'
  code <<-EOH
    mount -o loop /tmp/#{node['chef-bcs']['cobbler']['os']['distro']} /mnt
    cobbler import --name=#{node['chef-bcs']['cobbler']['os']['name']} --path=/mnt --breed=#{node['chef-bcs']['cobbler']['os']['breed']} --arch=#{node['chef-bcs']['cobbler']['os']['arch']}
    cobbler distro edit --name=#{node['chef-bcs']['cobbler']['os']['name']}-#{node['chef-bcs']['cobbler']['os']['arch']} --kopts="ksdevice= inst.repo=http://#{node['chef-bcs']['cobbler']['server']}/cblr/ks_mirror/#{node['chef-bcs']['cobbler']['os']['name']}-#{node['chef-bcs']['cobbler']['os']['arch']}"
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
    cobbler profile edit --name=#{node['chef-bcs']['cobbler']['profiles'][0]['name']} --netboot-enabled=true --comment="#{node['chef-bcs']['cobbler']['profiles'][0]['comment']}" --name-servers="#{node['chef-bcs']['dns']['servers'].join(' ')}"
    cobbler profile copy --name=#{node['chef-bcs']['cobbler']['profiles'][0]['name']} --newname=#{node['chef-bcs']['cobbler']['profiles'][1]['name']}
    cobbler profile edit --name=#{node['chef-bcs']['cobbler']['profiles'][1]['name']} --kickstart=/var/lib/cobbler/kickstarts/#{node['chef-bcs']['cobbler']['kickstart']['file']["#{node['chef-bcs']['cobbler']['profiles'][1]['file_type']}"]}
  EOH
  only_if "cobbler profile list"
  only_if "test -f /tmp/#{node['chef-bcs']['cobbler']['os']['distro']}"
end

# Update the Red Hat Satellite/Capsule/RHN info
if node['chef-bcs']['cobbler']['os']['breed'] == 'redhat' && node['chef-bcs']['cobbler']['redhat']['management']['type']
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
node['chef-bcs']['cobbler']['servers'].each do | server |
  if !server.roles.include? 'bootstrap'
    bash 'add-to-cobbler' do
      user 'root'
      code <<-EOH
        cobbler system add --name=#{server['name']} --profile=#{server['profile']} --static=true --interface=#{server['network']['public']['interface']} --mac=#{server['network']['public']['mac']} --ip-address=#{server['network']['public']['ip']} --netmask=#{server['network']['public']['netmask']} --if-gateway=#{server['network']['public']['gateway']} --hostname=#{server['name']} --mtu=#{server['network']['public']['mtu']}
        cobbler system edit --name=#{server['name']} --static=true --interface=#{server['network']['cluster']['interface']} --mac=#{server['network']['cluster']['mac']} --ip-address=#{server['network']['cluster']['ip']} --netmask=#{server['network']['cluster']['netmask']} --if-gateway=#{server['network']['cluster']['gateway']} --mtu=#{server['network']['cluster']['mtu']}
      EOH
      not_if "cobbler system list | grep #{server['name']}"
      only_if "test -f /tmp/#{node['chef-bcs']['cobbler']['os']['distro']}"
    end
  end
end

# Update mac addresses - PUBLIC and CLUSTER
# May want to add interfaces as an array so that any number of nic/mac can be added
# TODO: Also update for any bonded nics
node['chef-bcs']['cobbler']['servers'].each do | server |
  bash 'update-cobbler-macs' do
    user 'root'
    code <<-EOH
      cobbler system edit --name=#{server['name']} --static=true --interface=#{server['network']['public']['interface']} --mac=#{server['network']['public']['mac']} --ip-address=#{server['network']['public']['ip']} --netmask=#{server['network']['cluster']['netmask']} --if-gateway=#{server['network']['public']['gateway']} --mtu=#{server['network']['public']['mtu']}
      cobbler system edit --name=#{server['name']} --static=true --interface=#{server['network']['cluster']['interface']} --mac=#{server['network']['cluster']['mac']} --ip-address=#{server['network']['cluster']['ip']} --netmask=#{server['network']['cluster']['netmask']} --if-gateway=#{server['network']['cluster']['gateway']} --mtu=#{server['network']['cluster']['mtu']}
    EOH
    only_if "cobbler system list | grep #{server['name']}"
  end
end

# Cobbler will create the base pxe boot files needed. Every time you modify profile/system/distro you will need to do a cobbler sync
execute 'cobbler-sync' do
  command lazy{ "cobbler sync" }
  only_if "test -f /tmp/#{node['chef-bcs']['cobbler']['os']['distro']}"
end

# The block below is done for non-vagrant environments
if node['chef-bcs']['environment'] != 'vagrant'
  # NOTE: The items below can fail but also means it will have to be updated manually. This
  # NOTE: The /tmp/postinstall must exist
  execute 'tar-postinstall' do
    command lazy { "tar -zcvf /var/www/cobbler/pub/postinstall.tar.gz /tmp/postinstall/" }
    not_if "test -f /var/www/cobbler/pub/postinstall.tar.gz"
    # ignore_failure true
  end

  # Get the validate.pem and install client.rb into /var/www/cobbler/pub
  bash 'copy-chef-node' do
    user 'root'
    code <<-EOH
      sudo cp /etc/opscode/bcs-validator.pem /var/www/cobbler/pub/validation.pem
      sudo chmod 0644 /var/www/cobbler/pub/validation.pem
    EOH
    # ignore_failure true
  end

  template '/var/www/cobbler/pub/client.rb' do
    source 'client.rb.erb'
    mode '0644'
    # ignore_failure true
  end

  # NOTE: The kickstart process creates the directores, wgets the files to the node's /etc/chef and sets the permissions.
  # It then runs chef-client to verify
end
