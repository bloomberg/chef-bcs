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

# Set to Permissive
execute "selinux-permissive" do
    command "setenforce 0"
    not_if "getenforce | egrep -qx 'Permissive|Disabled'"
end

# This is to help as an example of setting variables needed for PXE booting using Cobbler
ruby_block 'initialize-cobbler-config' do
    block do
        make_config('cobbler-web-user', "cobbler")
        make_config('cobbler-web-password', secure_password)
        make_config('cobbler-web-password-digest', %x[ printf "#{get_config('cobbler-web-user')}:Cobbler:#{get_config('cobbler-web-password')}" | md5sum | awk '{print $1}' ])
        make_config('cobbler-root-password', secure_password)
        make_config('cobbler-root-password-salted', %x[ printf "#{get_config('cobbler-root-password')}" | mkpasswd -s -m sha-512 ])
    end
end

case node['platform']
when 'ubuntu'
  package 'isc-dhcp-server'
else
  # package 'dhcp'
  package 'dnsmasq'
  package 'syslinux'
  package 'pykickstart'
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

template "/var/lib/cobbler/kickstarts/#{node['chef-bcs']['kickstart']['file']}" do
    source "#{node['chef-bcs']['kickstart']['file']}.erb"
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

# cookbook_file "/tmp/#{node['chef-bcs']['cobbler']['distro']}.iso" do
#     source "#{node['chef-bcs']['cobbler']['distro']}.iso"
#     owner "root"
#     mode 00444
# end
