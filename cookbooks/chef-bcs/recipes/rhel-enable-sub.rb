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
# This recipe registers the rhel subscription with a Satellite/Capsule server.

if node['chef-bcs']['cobbler']['breed'] == 'redhat' && !node['chef-bcs']['cobbler']['repo_mirror'] && node['chef-bcs']['cobbler']['redhat_management_type'] != "off"
  execute 'rhel-enable-repo' do
    command "subscription-manager register --activationkey #{node['chef-bcs']['cobbler']['redhat_management_key']} --org \"Default_Organization\" --force"
  end
end

# NOTE: IF you're in a closed (private network) environment and do not have access to RHN or a Satellite/Capsule
# server then you can use the Red Hat Customer Portal and register the nodes. After that you can export the PEM
# file needed to be imported with subscription-manager import -- certificate=<whatever pem file>
# There is no recipe for it but you can easily add it.
