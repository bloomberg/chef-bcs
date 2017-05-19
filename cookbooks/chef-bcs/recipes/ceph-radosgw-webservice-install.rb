
include_recipe 'chef-bcs::ceph-conf'

# This recipe installs everything needed for the RGW Admin Web Service...

package 'nginx' do
    action :upgrade
end

include_recipe 'ceph-chef::ceph-radosgw-webservice-install'

# NB: May want to add a config file to hold admin user and keys etc.

# Add nginx directory for app
# Setup the NGINX config file. Since this is the only service using nginx we can just modify the nginx.conf directly.
template '/etc/nginx/nginx.conf' do
    source 'nginx.conf.erb'
    owner 'root'
    group 'root'
    # notifies :reload, "service[nginx]", :immediately
end

# NB: So rgw_webservice process can read ceph.conf
if node['chef-bcs']['ceph']['repo']['version']['name'] != 'hammer'
    execute "add_user_to_ceph" do
        command "usermod -a -G ceph nginx"
        ignore_failure true
    end
end

execute "add_nginx_to_radosgw" do
    command "usermod -a -G #{node['chef-bcs']['ceph']['radosgw']['rgw_webservice']['user']} nginx"
    ignore_failure true
end
