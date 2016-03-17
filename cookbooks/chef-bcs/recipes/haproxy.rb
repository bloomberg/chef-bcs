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

package 'haproxy' do
  action :upgrade
end

bash 'enable-defaults-haproxy' do
  user 'root'
  code <<-EOH
    sed --in-place '/^ENABLED=/d' /etc/default/haproxy
    echo 'ENABLED=1' >> /etc/default/haproxy
  EOH
  not_if "grep -e '^ENABLED=1' /etc/default/haproxy"
end

directory '/etc/ssl/private' do
  owner 'root'
  group 'root'
  mode 0700
  recursive true
  action :create
  not_if "test -d /etc/ssl/private"
end

#
# SSL Certs are unique to your environment so copy them over from a secure location during init phase of collecting your pre-reqs
#

bash 'copy-ssl-certs' do
  user 'root'
  code <<-EOH
    sudo cp /tmp/*.crt #{node['chef-bcs']['adc']['ssl']['path']}/.
    sudo chmod 0444 #{node['chef-bcs']['adc']['ssl']['path']}/*
  EOH
  only_if "test -f /tmp/*.crt"
end

# Set the config
template "/etc/haproxy/haproxy.cfg" do
  source 'haproxy.cfg.erb'
  variables lazy {
    {
      :backend_nodes => get_adc_backend_nodes,
      :server => get_server
    }
  }
end

if node['chef-bcs']['init_style'] == 'upstart'
else
  service 'haproxy' do
    restart_command "service haproxy stop && service haproxy start && sleep 5"
    provider Chef::Provider::Service::Redhat
    action [:enable, :start]
    supports :restart => true, :status => true
    subscribes :restart, "template[/etc/haproxy/haproxy.cfg]"
  end
end
