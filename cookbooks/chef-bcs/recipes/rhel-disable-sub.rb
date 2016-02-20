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
# This recipe disables the rhel subscription repo. You would use this if you were doing a repo_mirror on the
# bootstrap node instead of using Satellite/Capsule server for yum updates etc.

if node['chef-bcs']['cobbler']['breed'] == 'redhat' && node['chef-bcs']['cobbler']['repo_mirror']
  execute 'rhel-disable-repo' do
    command 'subscription-manager config --rhsm.manage_repos=0'
  end
end
