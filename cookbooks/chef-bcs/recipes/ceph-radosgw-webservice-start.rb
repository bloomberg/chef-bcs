include_recipe 'ceph-chef::ceph-radosgw-webservice-start'

execute 'rgw-webservice-nginx-start' do
    command 'sudo systemctl start nginx'
    ignore_failure true
end
