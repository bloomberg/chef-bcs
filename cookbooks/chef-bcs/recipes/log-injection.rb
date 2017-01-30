#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
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

# Ceph creates a number of logs. By default these logs are located on a partition on OS drives. A log partition can easily become
# full depending on log levels and activity in the cluster. To keep the log partition clean we inject the compressed logs into the
# ceph cluster itself for easy retrieval and maintenance. Of course, you could easily roll them off into something like Splunk or
# Graylog without injecting them into the cluster. However, having them stored in the cluster gives the option to retrieve at will
# and remove at will as well as push to somewhere else.

# IMPORTANT: Keep in mind the duration of storage! For large log files on each ceph node, you could easily become your own
# worst enemy from a space constraint standpoint.

# Create bcs_log_injection.sh
# This script gets created via the template and the log admin account credentials are used. These credentials can be anythng
# you want them to be. For example, you could create a separate set of credentials just for logs or use the default radosgw
# credentials etc.
template '/usr/local/bin/bcs_log_injection.py' do
  source 'bcs_log_injection.py.erb'
  mode   00755
  owner  'root'
  group  'root'
end
