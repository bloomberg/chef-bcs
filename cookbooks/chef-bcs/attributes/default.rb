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

# Change these to fit your organization
default['chef-bcs']['country'] = "US"
default['chef-bcs']['state'] = "NY"
default['chef-bcs']['location'] = "New York"
default['chef-bcs']['organization'] = "Bloomberg"

case node['platform']
when 'ubuntu'
  default['chef-bcs']['init_style'] = 'upstart'
else
  default['chef-bcs']['init_style'] = 'sysvinit'
end

default['chef-bcs']['enabled']['encrypt_data_bag'] = false

# Don't remove unless you set it somewhere else since this controls the firewalld cookbook
default['firewall']['allow_ssh'] = true
