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

include_recipe 'chef-bcs::ceph-conf'

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

# Should be disabled!
# Set to Permissive
# execute "selinux-permissive" do
#     command "setenforce 0"
#     not_if "getenforce | egrep -qx 'Permissive|Disabled'"
# end

case node['platform']
when 'ubuntu'
  package 'isc-dhcp-server'
else
  package 'dnsmasq'
  package 'tftp-server'
  package 'syslinux'
  package 'pykickstart'
  package 'xinetd'
  package 'createrepo'
  package 'fence-agents'  # power mgt for cobbler
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

# These would go in the environment json file in dhcp subnets section.
# Single subnet
#             {"subnet": "10.121.1.0", "tag": "rack1", "dhcp_range": ["10.121.1.3", "10.121.1.254"], "netmask": "255.255.255.0", "router": "10.121.1.2"}

# Multiple subnets
#            {"subnet": "10.121.1.0", "tag": "rack1", "dhcp_range": ["10.121.1.3", "10.121.1.30"], "netmask": "255.255.255.224", "router": "10.121.1.2"},
#            {"subnet": "10.121.1.32", "tag": "rack2", "dhcp_range": ["10.121.1.34", "10.121.1.62"], "netmask": "255.255.255.224", "router": "10.121.1.33"},
#            {"subnet": "10.121.1.64", "tag": "rack3", "dhcp_range": ["10.121.1.66", "10.121.1.94"], "netmask": "255.255.255.224", "router": "10.121.1.65"}

if node['chef-bcs']['cobbler']['dhcp']['subnets'].length > 1
  template '/etc/cobbler/dhcp.template' do
    source 'cobbler.dhcp.multiple.template.erb'
    mode 00644
  end

  template '/etc/cobbler/dnsmasq.template' do
    source 'cobbler.dnsmasq.multiple.template.erb'
    mode 00644
  end
else
  template '/etc/cobbler/dhcp.template' do
    source 'cobbler.dhcp.single.template.erb'
    mode 00644
    variables(
        :range => node['chef-bcs']['cobbler']['dhcp']['subnets'][0]['dhcp_range'].join(' '),
        :subnet => node['chef-bcs']['cobbler']['dhcp']['subnets'][0]['subnet']
    )
  end

  template '/etc/cobbler/dnsmasq.template' do
    source 'cobbler.dnsmasq.single.template.erb'
    mode 00644
    variables(
        :range => node['chef-bcs']['cobbler']['dhcp']['subnets'][0]['dhcp_range'].join(',')
    )
  end
end

template '/etc/cobbler/modules.conf' do
  source 'cobbler.modules.conf.erb'
  mode 00644
end

template "/var/lib/cobbler/kickstarts/#{node['chef-bcs']['cobbler']['kickstart']['file']['osd']}" do
  source "#{node['chef-bcs']['cobbler']['kickstart']['file']['osd']}.erb"
  mode 00644
end

template "/var/lib/cobbler/kickstarts/#{node['chef-bcs']['cobbler']['kickstart']['file']['nonosd']}" do
  source "#{node['chef-bcs']['cobbler']['kickstart']['file']['nonosd']}.erb"
  mode 00644
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
  cookbook_file "/tmp/#{node['chef-bcs']['cobbler']['os']['distro']}" do
    source "#{node['chef-bcs']['cobbler']['os']['distro']}"
    owner 'root'
    group 'root'
    mode 00444
  end
end

cookbook_file '/var/www/cobbler/pub/operations.pub' do
  source 'operations.pub'
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
