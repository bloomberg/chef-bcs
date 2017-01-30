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

# Set cron up to push logs into the given cluster and then remove them to keep the log partitions clean. The log data
# can then be pulled down by other log tools if desired since a log user account is created for each federated zone.

include_recipe 'chef-bcs::log-injection'

# Activate crontab
cron 'log-injection-daily' do
  user    'root'
  minute  '30'
  hour    '4'
  command "/usr/local/bin/bcs_log_injection.py daily"
end
