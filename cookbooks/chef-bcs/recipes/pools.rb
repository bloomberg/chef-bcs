#
# Author: Chris Jones <cjones303@bloomberg.net>
# Cookbook: chef-bcs
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

# Original ceph-osd-pools role
# "run_list": [
#   "recipe[chef-bcs::erasure-coding]",
#   "recipe[ceph-chef::pools_create]",
#   "recipe[ceph-chef::pools_set]"
# ]

# Modified the pools so that the erasure-coding recipe and other set the pool information. May move upstream later.

# Apply the crush map rule to the pools

if node['chef-bcs']['ceph']['pools']['radosgw']['federated']['enable']
  node_loop = node['ceph']['pools']['radosgw']['federated_names']
  node_loop.each do |name|
    execute "pool-crushmap-rule-#{name}" do
      command lazy { "ceph osd pool set #{name} crush_ruleset #{node['chef-bcs']['ceph']['pools']['radosgw']['settings']['crush_rule_set']}" }
      notifies :run, "bash[wait-for-pgs-creating]", :immediately
    end
  end
else
  node_loop = node['ceph']['pools']['radosgw']['pools']
  node_loop.each do |pool_val|
    execute "pool-crushmap-rule-#{pool_val['name']}" do
      command lazy { "ceph osd pool set #{pool_val['name']} crush_ruleset #{node['chef-bcs']['ceph']['pools']['radosgw']['settings']['crush_rule_set']}" }
      notifies :run, "bash[wait-for-pgs-creating]", :immediately
    end
  end
end

# Safety precaution so as to not overload the mon nodes.
bash "wait-for-pgs-creating" do
    action :nothing
    user "root"
    # code "sleep 1; while ceph -s | grep -v mdsmap | grep creating >/dev/null 2>&1; do echo Waiting for new pgs to create...; sleep 1; done"
    code "while [ $(ceph -s | grep creating -c) -gt 0 ]; do echo -n .;sleep 1; done"
end
