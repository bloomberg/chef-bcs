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

# NOTE: ipv4 forwarding rule is applied in the keepalived recipe which is needed for bgp

if node['chef-bcs']['adc']['bgp']['enable']
  package 'bird' do
    action :upgrade
  end

  # The above package should be 1.5.0 or higher but I have seen 1.4.5 in older repos. The rpm is included in
  # /ceph-files/ with the latest version of bird so that it can be installed instead if needed.

  # Set the config
  template "/etc/bird.conf" do
    source 'bird.conf.erb'
    variables lazy {
      {
        :interface_ip => get_bgp_interface_ip,
        :is_adc_node_secondary => is_adc_node_role('secondary')
      }
    }
  end

  if node['chef-bcs']['init_style'] == 'upstart'
  else
    execute 'bird-enable' do
      command 'sudo systemctl enable bird'
    end
    execute 'bird-start' do
      command 'sudo systemctl start bird'
    end
  end
end
