#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
# Recipe:: cobbler-firewall
#
# Copyright 2015, Bloomberg Finance L.P.
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

# FirewallD rules for restapi
# open standard http port to tcp traffic only; insert as first rule
# 443 is not required since civetweb does not terminate SSL. Use anyone of the following to terminate SSL traffic:
# Hardware load balancer
# Software load balancer
# Proxy like NGINX or something that can terminate SSL and then proxy on to rgw
# Can also tighten even further by only allowing traffic from upstream load balancer etc...

firewall_rule 'http' do
  port node['chef-bcs']['cobbler']['http_port']
  command :allow
end

firewall_rule 'https' do
  port node['chef-bcs']['cobbler']['https_port']
  command :allow
end

firewall_rule 'xmlrpc' do
  port node['chef-bcs']['cobbler']['xmlrpc_port']
  command :allow
end

firewall_rule 'cobbler-api' do
  port 25150
  command :allow
end

firewall_rule 'dhcp' do
  port 69
  interface node['chef-bcs']['cobbler']['pxe_interface']
  command :allow
end

firewall_rule 'dns' do
  port 53
  interface node['chef-bcs']['cobbler']['pxe_interface']
  command :allow
end

firewall 'default' do
  action :save
end
