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

# PURPOSE:
# This recipe builds the environment variable files used by the automation to know which host belong to which
# role. For example, for ADC nodes a file called ceph_chef_adc_hosts.env will be create be created from the
# Cobbler server list if the given record contains a role of 'adc'. These files are sourced during the build process
# that controls the execution of Chef Roles and Recipes on all of the nodes.

ceph_chef_adc_hosts_content = 'export CEPH_ADC_HOSTS=( '
ceph_chef_admin_hosts_content = 'export CEPH_ADMIN_HOSTS=( '
ceph_chef_mon_hosts_content = 'export CEPH_MON_HOSTS=( '
ceph_chef_osd_hosts_content = 'export CEPH_OSD_HOSTS=( '
ceph_chef_osd_rack01_hosts_content = 'export CEPH_OSD_RACK01_HOSTS=( '
ceph_chef_osd_rack02_hosts_content = 'export CEPH_OSD_RACK02_HOSTS=( '
ceph_chef_osd_rack03_hosts_content = 'export CEPH_OSD_RACK03_HOSTS=( '
ceph_chef_rgw_hosts_content = 'export CEPH_RGW_HOSTS=( '
ceph_chef_hosts_content = 'export CEPH_CHEF_HOSTS=( '
ceph_chef_bootstrap_content = 'export CEPH_CHEF_BOOTSTRAP='

# Server list
node['chef-bcs']['cobbler']['servers'].each do | server |
  server['roles'].each do | role |
    case role
    when 'bootstrap'
      ceph_chef_bootstrap_content += (server['name'] + "\n" + 'export CEPH_CHEF_BOOTSTRAP_IP=' + server['network']['public']['ip'])
    when 'adc'
      ceph_chef_adc_hosts_content += (server['name'] + ' ')
    when 'admin'
      ceph_chef_admin_hosts_content += (server['name'] + ' ')
    when 'mon'
      ceph_chef_mon_hosts_content += (server['name'] + ' ')
    when 'osd'
      ceph_chef_osd_hosts_content += (server['name'] + ' ')
      if server['name'].include? 'r1n'
        ceph_chef_osd_rack01_hosts_content += (server['name'] + ' ')
      end
      if server['name'].include? 'r2n'
        ceph_chef_osd_rack02_hosts_content += (server['name'] + ' ')
      end
      if server['name'].include? 'r3n'
        ceph_chef_osd_rack03_hosts_content += (server['name'] + ' ')
      end
      if server['name'].include? 'r1a'
        ceph_chef_osd_rack01_hosts_content += (server['name'] + ' ')
      end
      if server['name'].include? 'r2b'
        ceph_chef_osd_rack02_hosts_content += (server['name'] + ' ')
      end
      if server['name'].include? 'r3c'
        ceph_chef_osd_rack03_hosts_content += (server['name'] + ' ')
      end
    when 'rgw'
      ceph_chef_rgw_hosts_content += (server['name'] + ' ')
    end
    ceph_chef_hosts_content += (server['name'] + ' ')
  end
end

# Bootstrap is not a list like the others
ceph_chef_adc_hosts_content += ')'
ceph_chef_admin_hosts_content += ')'
ceph_chef_mon_hosts_content += ')'
ceph_chef_osd_hosts_content += ')'
ceph_chef_osd_rack01_hosts_content += ')'
ceph_chef_osd_rack02_hosts_content += ')'
ceph_chef_osd_rack03_hosts_content += ')'
ceph_chef_rgw_hosts_content += ')'
ceph_chef_hosts_content += ')'

user_rec = node['chef-bcs']['cobbler']['kickstart']['users'].first
env = node['chef-bcs']['bootstrap']['env']

# NOTE: file_name is also the variable names
%w{ceph_chef_hosts ceph_chef_adc_hosts ceph_chef_admin_hosts ceph_chef_mon_hosts ceph_chef_osd_hosts ceph_chef_rgw_hosts ceph_chef_bootstrap}.each do | file_name |
  file "#{env}/#{file_name}.env" do
    case file_name
    when 'ceph_chef_adc_hosts'
      content "#{ceph_chef_adc_hosts_content}"
    when 'ceph_chef_admin_hosts'
      content "#{ceph_chef_admin_hosts_content}"
    when 'ceph_chef_mon_hosts'
      content "#{ceph_chef_mon_hosts_content}"
    when 'ceph_chef_osd_hosts'
      content "#{ceph_chef_osd_hosts_content}\n#{ceph_chef_osd_rack01_hosts_content}\n#{ceph_chef_osd_rack02_hosts_content}\n#{ceph_chef_osd_rack03_hosts_content}"
    when 'ceph_chef_rgw_hosts'
      content "#{ceph_chef_rgw_hosts_content}"
    when 'ceph_chef_bootstrap'
      content "#{ceph_chef_bootstrap_content}"
    when 'ceph_chef_hosts'
      content "#{ceph_chef_hosts_content}"
    end
    mode '0755'
    owner user_rec['name']
    group user_rec['groups']
  end
end
