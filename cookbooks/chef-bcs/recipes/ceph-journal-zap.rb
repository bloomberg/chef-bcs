#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
# Recipe:: ceph-osd
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

package 'gdisk'

# Remove the journal partitions
journals = get_journals
if !journals.empty?
  journals.each do | journal |
    execute "ceph-journal-zap for #{journal}" do
      command <<-EOH
        for i in $(sgdisk #{journal} -p | grep ceph | awk '{print $1}'); do
          sgdisk #{journal} -d $i
        done
      EOH
      action :run
    end
  end
end
