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

package 'gdisk'

if node['ceph']['osd']['devices']
  devices = node['ceph']['osd']['devices']

  devices = Hash[(0...devices.size).zip devices] unless devices.is_a? Hash

  devices.each do |index, osd_device|
    dmcrypt = osd_device['encrypted'] == true ? '--dmcrypt' : ''

    execute "ceph-disk-zap on #{osd_device['data']}" do
      command <<-EOH
        dd if=/dev/zero of=#{osd_device['data']} bs=512 count=1 conv=notrunc
        sgdisk --zap-all #{osd_device['data']}
      EOH
      only_if "sgdisk -i1 #{osd_device['data']} | grep -i 4fbd7e29-9d25-41b8-afd0-062c0ceff05d" if !dmcrypt
      only_if "sgdisk -i1 #{osd_device['data']} | grep -i 4fbd7e29-9d25-41b8-afd0-5ec00ceff05d" if dmcrypt
      only_if "parted --script #{osd_device['data']} print | egrep -sq '^ 1.*ceph'"
      action :run
    end
  end
else
  Log.info("node['ceph']['osd']['devices'] empty")
end
