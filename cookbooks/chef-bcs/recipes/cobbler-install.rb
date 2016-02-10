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

package 'whois'

# Generate web_user_pwd and save. NOTE: This attribute 'web_user_pwd' is not in an environment file!
if node['chef-bcs']['cobbler']['web_user_pwd'].nil?
  ruby_block 'gen-web-user-pwd' do
    block do
      node.set['chef-bcs']['cobbler']['web_user_pwd'] = %x[ printf "#{node['chef-bcs']['cobbler']['web_user']}:Cobbler:#{secure_password()}" | md5sum | awk '{print $1}' ]
      node.save
    end
  end
end

# Set to Permissive
execute "selinux-permissive" do
    command "setenforce 0"
    not_if "getenforce | egrep -qx 'Permissive|Disabled'"
end

case node['platform']
when 'ubuntu'
  package 'isc-dhcp-server'
else
  package 'dnsmasq'
  package 'tftp-server'
  package 'syslinux'
  package 'pykickstart'
  package 'xinetd'
end

package 'cobbler'
package 'cobbler-web'
# ipmitool is mainly used for power mgt.
package 'ipmitool'

template '/etc/cobbler/settings' do
    source 'cobbler.settings.erb'
    mode 00644
end

template '/etc/cobbler/users.digest' do
    source 'cobbler.users.digest.erb'
    mode 00600
end

template '/etc/cobbler/dhcp.template' do
    source 'cobbler.dhcp.template.erb'
    mode 00644
    variables(
        :range => node['chef-bcs']['cobbler']['dhcp_range'].join(' '),
        :subnet => node['chef-bcs']['cobbler']['dhcp_subnet']
    )
end

template '/etc/cobbler/dnsmasq.template' do
    source 'cobbler.dnsmasq.template.erb'
    mode 00644
    variables(
        :range => node['chef-bcs']['cobbler']['dhcp_range'].join(',')
    )
end

# NOTE: These next one aid in starting dhcp and dnsmasq *before* cobbler does a 'cobbler sync'. They will get
# overridden on sync.
template '/etc/dnsmasq.conf' do
    source 'cobbler.dnsmasq.template.erb'
    mode 00644
    variables(
      :range => node['chef-bcs']['cobbler']['dhcp_range'].join(',')
    )
end

template '/etc/cobbler/modules.conf' do
    source 'cobbler.modules.conf.erb'
    mode 00644
end

parts = node['chef-bcs']['cobbler']['partitions']

# NOTE: This is for the BCS NODE kickstart and not the bootstrap kickstart.
# Add the following in the erb file later
# <%= node['chef-bcs']['cobbler']['partition_option'] %>
# <% @parts.each do |part| %>
# part <%= part['part'] %> --fstype=<%= part['fstype'] %> --size=<%= part['size'] %> <%= part['options'] %>
# <% end %>

# unless parts.is_a? Hash
template "/var/lib/cobbler/kickstarts/#{node['chef-bcs']['cobbler']['kickstart']['file']}" do
    source "#{node['chef-bcs']['cobbler']['kickstart']['file']}.erb"
    mode 00644
    variables(
      :parts => Hash[(0...parts.size).zip parts]
    )
end

# NOTE: This removes the default SSL from Apache so that Chef Server (NGINX) has no issues. However, this will not allow the web ui of Cobbler to be accessed.
case node['platform']
when 'ubuntu'
else
  execute 'Rename' do
    command 'mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.cobbler'
    only_if "test -f /etc/httpd/conf.d/ssl.conf"
  end
end

# NOTE: *.iso are blocked from github push/pull via .gitignore so download desired ISO and put it into files directory.
if ENV.has_key?('COBBLER_BOOTSTRAP_ISO')
  cookbook_file "/tmp/#{node['chef-bcs']['cobbler']['distro']}" do
    source "#{node['chef-bcs']['cobbler']['distro']}"
    owner 'root'
    group 'root'
    mode 00444
  end
end

# Load the loaders simply for completness so the only thing that should ever run on the cli is the following:
# cobbler sync
# cobbler system <whatever commands>
# cobbler profile <whatever commands>
# cobbler import <whatever commands>
%w{ grub-x86_64.efi  grub-x86.efi  menu.c32  pxelinux.0 }.each do |ext|
  cookbook_file "/var/lib/cobbler/loaders/#{ext}" do
    source "loaders/#{ext}"
    not_if "test -f /var/lib/cobbler/loaders/#{ext}"
  end
end
