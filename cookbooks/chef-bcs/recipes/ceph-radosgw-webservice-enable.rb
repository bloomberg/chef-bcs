include_recipe 'ceph-chef::ceph-radosgw-webservice-enable'

execute 'rgw-webservice-nginx-enable' do
    command 'sudo systemctl enable nginx'
    ignore_failure true
end
