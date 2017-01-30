#
# Author: Chris Jones <cjones303@bloomberg.net>
# Cookbook: chef-bcs
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

# This recipe must run after the ceph-chef::osd recipe to set the crush map settings.

if node['chef-bcs']['ceph']['osd']['devices'] && node['ceph']['osd']['crush']['update']
  devices = node['chef-bcs']['ceph']['osd']['devices']

  devices = Hash[(0...devices.size).zip devices] unless devices.is_a? Hash

  devices.each do |index, osd_device|

    unless osd_device['status'].nil? || osd_device['status'] != 'deployed'
      Log.info("Crushmap: osd device '#{osd_device}' has not been setup.")
      next
    end

    rack_num = get_rack_num(node['hostname'])

    # Added data_type as part of host name so that ceph osd tree can show which hosts are ssd and which are hdd. Rack does not have to reflect data_type.
    # CLEAN UP later...just for testing options........
    # Added rack to chooseleaf = host too
    if node['chef-bcs']['ceph']['pools']['radosgw']['settings']['chooseleaf'] == 'host'
      execute "crushmap-set-#{osd_device['data']}" do
        command <<-EOH
          INFO=`df -k | grep #{osd_device['data']} | awk '{print $2,$6}' | sed -e 's/\\/var\\/lib\\/ceph\\/osd\\/ceph-//'`
          OSD=${INFO#* }
          WEIGHT=`echo "scale=4; ${INFO% *}/1000000000.0" | bc -q`
          ceph osd crush create-or-move $OSD $WEIGHT root=#{osd_device['data_type']} rack=rack#{rack_num} host=#{node['hostname']}
        EOH
        action :run
        notifies :create, "ruby_block[save-status-#{index}]", :immediately
      end
    else
      execute "crushmap-set-#{osd_device['data']}" do
        command <<-EOH
          INFO=`df -k | grep #{osd_device['data']} | awk '{print $2,$6}' | sed -e 's/\\/var\\/lib\\/ceph\\/osd\\/ceph-//'`
          OSD=${INFO#* }
          WEIGHT=`echo "scale=4; ${INFO% *}/1000000000.0" | bc -q`
          ceph osd crush create-or-move $OSD $WEIGHT root=#{osd_device['data_type']} rack=rack#{rack_num} host=#{node['hostname']}
        EOH
        action :run
        notifies :create, "ruby_block[save-status-#{index}]", :immediately
      end
    end

    ruby_block "save-status-#{index}" do
      block do
        node.normal['chef-bcs']['ceph']['osd']['devices'][index]['status'] = 'deployed'
        node.save
      end
      action :nothing
    end

  end

  execute 'trigger-osd-startup' do
    command "udevadm trigger --subsystem-match=block --action=add"
  end
end
