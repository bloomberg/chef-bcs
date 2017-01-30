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

package 'haproxy' do
  action :upgrade
end

bash 'enable-defaults-haproxy' do
  user 'root'
  code <<-EOH
    sed --in-place '/^ENABLED=/d' /etc/default/haproxy
    echo 'ENABLED=1' >> /etc/default/haproxy
  EOH
  not_if "grep -e '^ENABLED=1' /etc/default/haproxy"
end

#
# SSL Certs are unique to your environment so copy them over from a secure location during init phase of collecting your pre-reqs
#
directory '/etc/ssl/private' do
  owner 'root'
  group 'root'
  mode 0700
  recursive true
  action :create
  not_if "test -d /etc/ssl/private"
end

bash 'copy-ssl-certs' do
  user 'root'
  code <<-EOH
    sudo cp /tmp/*.pem #{node['chef-bcs']['adc']['ssl']['path']}/.
    sudo cp /tmp/*.crt #{node['chef-bcs']['adc']['ssl']['path']}/.
    sudo cp /tmp/*.key #{node['chef-bcs']['adc']['ssl']['path']}/.
    sudo chmod 0444 #{node['chef-bcs']['adc']['ssl']['path']}/*
  EOH
  ignore_failure true
end

# Can optimize later...
node['chef-bcs']['adc']['vips'].each do | vip |
  if vip['ssl'] == true && !File.exists?("#{vip['cert']}")
    execute 'dev-null-cert' do
     command lazy { "cp /dev/null #{node['chef-bcs']['adc']['ssl']['path']}/#{vip['cert']}" }
    end

    # IF ssl_files contains more than one file name it will build a cert from those files. If just a wildcard then only one file should be in the list
    vip['ssl_files'].each do | ssl_file |
      bash "build-ssl-cert-#{vip['name']}" do
        user 'root'
        code <<-EOH
          if [[ #{node['chef-bcs']['adc']['ssl']['path']}/#{ssl_file} != #{node['chef-bcs']['adc']['ssl']['path']}/#{vip['cert']} ]]; then
            cat #{node['chef-bcs']['adc']['ssl']['path']}/#{ssl_file} >> #{node['chef-bcs']['adc']['ssl']['path']}/#{vip['cert']}
          fi
        EOH
      end
    end

    execute 'chmod-cert' do
     command lazy { "chmod 0444 #{node['chef-bcs']['adc']['ssl']['path']}/#{vip['cert']}" }
    end
  end
end
# SSL End

#
# Directory for haproxy stats sockets
#
directory '/var/run/haproxy' do
  owner 'root'
  group 'root'
  mode 0755
end

# NOTE: Sample data structure (Federated Example) - ONLY applies if do it manually, if using the template version the VIPs info will do all of it for you.
# {"name": "ceph-vm1", "instance": "admin", "weight": 6, "port": 8080, "options": "check inter 2s rise 2 fall 3"}
# The 'instance' variable represents the radosgw instance name and the vip name. So, *ALL* three values should match for lookups to work:
# VIPS: name variable, BACKEND/SERVERS: instance variable and CEPH/POOLS/RADOSGW/FEDERATED/INSTANCES name variable

# NOTE: Sample data structure (NON-Federated Example)
# {"name": "ceph-vm1", "instance": "", "weight": 6, "port": 8080, "options": "check inter 2s rise 2 fall 3"}
# The 'instance' variable is empty! No federation matching will be attempted.

# Set the config
template "/etc/haproxy/haproxy.cfg" do
  source 'haproxy.cfg.erb'
  variables lazy {
    {
      :backend_nodes => node['chef-bcs']['ceph']['pools']['radosgw']['federated']['enable'] ? get_adc_backend_federated_nodes : get_adc_backend_nodes,
      :server => get_server
    }
  }
end

if node['chef-bcs']['init_style'] == 'upstart'
else
  # Broke out the service resources for better idempotency.
  service 'haproxy' do
    action [:enable]
    only_if "sudo systemctl status haproxy | grep disabled"
  end

  service 'haproxy' do
    restart_command "service haproxy stop && service haproxy start && sleep 5"
    action [:start]
    supports :restart => true, :status => true
    subscribes :restart, "template[/etc/haproxy/haproxy.cfg]"
  end
end
