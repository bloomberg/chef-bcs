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

node.default['collectd']['service']['configuration']['hostname'] = node['fqdn']
node.default['collectd']['service']['configuration']['interval'] = 15
node.default['collectd']['service']['configuration']['plugin_dir'] = '/usr/lib64/collectd'
node.default['collectd']['service']['user'] = 'root'
node.default['collectd']['service']['group'] = 'root'
node.default['collectd-plugins']['cpu']['report_by_cpu'] = false
node.default['collectd-plugins']['df']['f_s_type'] = 'proc', 'sysfs', 'fusectl', 'debugfs', 'securityfs', 'devtmpfs', 'devpts', 'tmpfs', 'nfs', 'vboxsf'
node.default['collectd-plugins']['df']['mount_point'] = get_osd_mountpoints
node.default['collectd-plugins']['df']['ignore_selected'] = true
node.default['collectd-plugins']['df']['report_inodes'] = true
node.default['collectd-plugins']['df']['values_percentage'] = true
node.default['collectd-plugins']['memory']['values_percentage'] = true
node.default['collectd-plugins']['processes']['process_total_only'] = true
node.default['collectd-plugins']['swap']['report_by_device'] = false
node.default['collectd-plugins']['write_graphite']['node']['id'] = node['chef-bcs']['collectd-plugins']['write_graphite']['node']['id']
node.default['collectd-plugins']['write_graphite']['node']['host'] = node['chef-bcs']['collectd-plugins']['write_graphite']['node']['host']
node.default['collectd-plugins']['write_graphite']['node']['port'] = node['chef-bcs']['collectd-plugins']['write_graphite']['node']['port']
node.default['collectd-plugins']['write_graphite']['node']['prefix'] = node['chef-bcs']['collectd-plugins']['write_graphite']['node']['prefix']

include_recipe 'collectd::default'

service 'collectd' do
  provider Chef::Provider::Service::Systemd
  action :start
end

include_recipe 'collectd_plugins::default'
include_recipe 'collectd_plugins::disk'
include_recipe 'collectd_plugins::processes'
include_recipe 'collectd_plugins::syslog'
include_recipe 'collectd_plugins::write_graphite'

%w{entropy}.each do |plugin|
  collectd_plugin "#{plugin}" do
    notifies :restart, 'service[collectd]', :delayed
  end
end

package 'collectd-ceph' do
  action :install
end

node.default['chef-bcs']['collectd-plugins']['ceph']['daemons'] = get_ceph_sockets

collectd_plugin_file 'ceph' do
  plugin_name 'ceph'
  plugin_instance_name node['chef-bcs']['environment']
  source 'collectd-ceph.conf.erb'
  notifies :restart, 'service[collectd]', :delayed
end

# Simple template for filtering metrics
template '/etc/collectd.d/filter.conf' do
  source 'collectd-filter.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, 'service[collectd]', :delayed
end
