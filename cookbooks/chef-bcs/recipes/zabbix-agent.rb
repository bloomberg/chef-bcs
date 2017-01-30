#
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

cookbook_file '/etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX' do
  source 'RPM-GPG-KEY-ZABBIX'
  owner 'root'
  group 'root'
  mode 00644
end

if node['chef-bcs']['cobbler']['redhat']['management']['type'] == 'off'
  yum_repository 'zabbix' do
    baseurl node['chef-bcs']['zabbix']['repository']
    gpgkey node['chef-bcs']['zabbix']['repository_key']
  end
end

%w{zabbix-agent zabbix-sender}.each do |pkg|
  package "#{pkg}" do
    action :install
  end
end

template '/etc/zabbix/zabbix_agentd.conf' do
  source 'zabbix-zabbix_agentd.conf.erb'
  owner 'zabbix'
  group 'root'
  mode 00600
  variables(
    :zabbix_server => node['chef-bcs']['zabbix']['server'],
    :agent_ip      => get_bond_ip,
    :tags          => node.tags
  )
  notifies :restart, 'service[zabbix-agent]', :delayed
end

%w{ ceph radosgw haproxy raid }.each do |component|
  template "/etc/zabbix/zabbix_agentd.d/userparameter_#{component}.conf" do
    source "zabbix-userparameter-#{component}.conf.erb"
    owner 'zabbix'
    group 'root'
    mode '00600'
    notifies :restart, 'service[zabbix-agent]', :delayed
  end
end

execute 'systemd-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

directory '/etc/systemd/system/zabbix-agent.service.d' do
  owner 'root'
  group 'root'
  mode 00755
end

cookbook_file '/usr/local/bin/raid_status.sh' do
  source 'zabbix_scripts/raid_status.sh'
  owner 'root'
  group 'root'
  mode 00755
end

cookbook_file '/etc/systemd/system/zabbix-agent.service.d/service.conf' do
  source 'zabbix-systemd-service.conf'
  owner 'root'
  group 'root'
  mode 00644
  notifies :run, 'execute[systemd-reload]', :immediately
end

service 'zabbix-agent' do
  provider Chef::Provider::Service::Systemd
  action [:enable]
end
