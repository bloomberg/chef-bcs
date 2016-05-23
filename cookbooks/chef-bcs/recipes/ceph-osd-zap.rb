#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
# Recipe:: ceph-osd
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

include_recipe 'chef-bcs::ceph-conf'
include_recipe 'ceph-chef::osd_stop_all'

package 'gdisk'

if node['ceph']['osd']['devices']
  devices = node['ceph']['osd']['devices']

  devices = Hash[(0...devices.size).zip devices] unless devices.is_a? Hash

  devices.each do |index, osd_device|
    dmcrypt = osd_device['encrypted'] == true ? '--dmcrypt' : ''

    # No reason for a gaurd since it works or it doesn't.
    execute "ceph-disk-zap on #{osd_device['data']}" do
      command <<-EOH
        dd if=/dev/zero of=#{osd_device['data']} bs=512 count=1 conv=notrunc
        sgdisk --zap-all #{osd_device['data']}
      EOH
      action :run
    end
  end

  # Reset back to initial install by removing normal attribute of ceph osd devices
  ruby_block 'null osd_device status' do
    block do
      node.rm_normal('ceph', 'osd')
    end
    action :run
  end

  include_recipe 'chef-bcs::ceph-journal-zap'
else
  Log.info("node['ceph']['osd']['devices'] empty")
end
