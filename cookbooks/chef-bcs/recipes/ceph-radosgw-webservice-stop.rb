include_recipe 'ceph-chef::ceph-radosgw-webservice-stop'

execute 'rgw-webservice-nginx-stop' do
    command 'sudo systemctl stop nginx'
    ignore_failure true
end
