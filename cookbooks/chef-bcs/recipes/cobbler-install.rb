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
ruby_block 'gen-web-user-pwd' do
  block do
    node.set['chef-bcs']['cobbler']['web_user_pwd'] = %x[ printf "#{node['chef-bcs']['cobbler']['web_user']}:Cobbler:#{secure_password()}" | md5sum | awk '{print $1}' ]
    node.save
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
  # package 'dhcp'
  package 'dnsmasq'
  package 'syslinux'
  package 'pykickstart'
  package 'xinetd'
end

package 'cobbler'
package 'cobbler-web'

template '/etc/cobbler/settings' do
    source 'cobbler.settings.erb'
    mode 00644
    # notifies :restart, 'service[cobbler]', :delayed
end

template '/etc/cobbler/users.digest' do
    source 'cobbler.users.digest.erb'
    mode 00600
end

template '/etc/cobbler/dhcp.template' do
    source 'cobbler.dhcp.template.erb'
    mode 00644
    variables(
        :range => node['chef-bcs']['cobbler']['dhcp_range'],
        :subnet => node['chef-bcs']['cobbler']['dhcp_subnet']
    )
    # notifies :restart, 'service[cobbler]', :delayed
end

template '/etc/cobbler/dnsmasq.template' do
    source 'cobbler.dnsmasq.template.erb'
    mode 00644
    variables(
        :range => node['chef-bcs']['cobbler']['dhcp_range']
    )
end

template '/etc/cobbler/modules.conf' do
    source 'cobbler.modules.conf.erb'
    mode 00644
end

template "/var/lib/cobbler/kickstarts/#{node['chef-bcs']['cobbler']['kickstart']['file']}" do
    source "#{node['chef-bcs']['cobbler']['kickstart']['file']}.erb"
    mode 00644
end

case node['platform']
when 'ubuntu'
else
  execute 'Rename' do
    command 'mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.cobbler'
    only_if "test -f /etc/httpd/conf.d/ssl.conf"
  end
end

# NOTE: *.iso are blocked from github push/pull via .gitignore so download desired ISO and put it into files directory.
if ENV.has_key?('BOOTSTRAP_OS')
  cookbook_file "/tmp/#{node['chef-bcs']['cobbler']['distro']}.iso" do
    source "#{node['chef-bcs']['cobbler']['distro']}.iso"
    owner 'root'
    group 'root'
    mode 00444
  end
end

remote_directory "/var/lib/cobbler/loaders/" do
  source "loaders"
  action :create_if_missing
end
