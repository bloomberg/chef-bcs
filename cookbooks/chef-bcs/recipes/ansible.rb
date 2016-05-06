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
# This recipe builds the Ansible inventory files needed to aid in maintenance and orchestration

# Since Ansible works best with an SSH key. Don't forget to do the following before using adhoc ansible or playbook
# commands: (this keeps you from getting a security prompt)
# ssh-agent bash
# ssh-add ~/.ssh/id_rsa  (or whatever you called your key)

# Maintenance tools
# Ansible is used for what it's best used for, good ssh pipe and orchestration
package 'ansible'

ceph_chef_adc_hosts_content = ''
ceph_chef_admin_hosts_content = ''
ceph_chef_mon_hosts_content = ''
ceph_chef_osd_hosts_content = ''
ceph_chef_osd_rack01_hosts_content = ''
ceph_chef_osd_rack02_hosts_content = ''
ceph_chef_osd_rack03_hosts_content = ''
ceph_chef_rgw_hosts_content = ''
ceph_chef_bootstrap_content = ''

# Server list
node['chef-bcs']['cobbler']['servers'].each do | server |
  server['roles'].each do | role |
    case role
    when 'bootstrap'
      ceph_chef_bootstrap_content += (server['name'] + "\n")
    when 'adc'
      ceph_chef_adc_hosts_content += (server['name'] + "\n")
    when 'admin'
      ceph_chef_admin_hosts_content += (server['name'] + "\n")
    when 'mon'
      ceph_chef_mon_hosts_content += (server['name'] + "\n")
    when 'osd'
      ceph_chef_osd_hosts_content += (server['name'] + "\n")
      if server['name'].include? 'r1n'
        ceph_chef_osd_rack01_hosts_content += (server['name'] + "\n")
      end
      if server['name'].include? 'r2n'
        ceph_chef_osd_rack02_hosts_content += (server['name'] + "\n")
      end
      if server['name'].include? 'r3n'
        ceph_chef_osd_rack03_hosts_content += (server['name'] + "\n")
      end
    when 'rgw'
      ceph_chef_rgw_hosts_content += (server['name'] + "\n")
    end
  end
end

ceph_chef_ansible_content = "[bootstrap]\n" + ceph_chef_bootstrap_content + "\n\n"
ceph_chef_ansible_content += ceph_chef_ansible_content + "[adc]\n" + ceph_chef_adc_hosts_content + "\n\n"
ceph_chef_ansible_content += ceph_chef_ansible_content + "[admin]\n" + ceph_chef_admin_hosts_content + "\n\n"
ceph_chef_ansible_content += ceph_chef_ansible_content + "[mon]\n" + ceph_chef_mon_hosts_content + "\n\n"
ceph_chef_ansible_content += ceph_chef_ansible_content + "[osd]\n" + ceph_chef_osd_hosts_content + "\n\n"
ceph_chef_ansible_content += ceph_chef_ansible_content + "[osd-rack01]\n" + ceph_chef_osd_rack01_hosts_content + "\n\n"
ceph_chef_ansible_content += ceph_chef_ansible_content + "[osd-rack02]\n" + ceph_chef_osd_rack02_hosts_content + "\n\n"
ceph_chef_ansible_content += ceph_chef_ansible_content + "[osd-rack03]\n" + ceph_chef_osd_rack03_hosts_content + "\n\n"
ceph_chef_ansible_content += ceph_chef_ansible_content + "[rgw]\n" + ceph_chef_rgw_hosts_content + "\n\n"

# NOTE: The default ansible /etc/ansible directory
file '/etc/ansible/hosts' do
  content "#{ceph_chef_ansible_content}"
  mode '0644'
end
