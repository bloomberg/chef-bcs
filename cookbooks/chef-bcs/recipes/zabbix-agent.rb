#
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
    :agent_ip      => get_bond_ip
  )
  notifies :restart, 'service[zabbix-agent]', :delayed
end

%w{ ceph radosgw haproxy }.each do |component|
  template "/etc/zabbix/zabbix_agentd.d/userparameter_#{component}.conf" do
    source "zabbix-userparameter-#{component}.conf.erb"
    owner 'zabbix'
    group 'root'
    mode '00600'
    notifies :restart, 'service[zabbix-agent]', :delayed
  end
end

service 'zabbix-agent' do
  provider Chef::Provider::Service::Systemd
  action [:enable, :start]
end
