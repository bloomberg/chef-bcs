#!/bin/bash
#
# Author: Chris Jones <cjones303@bloomberg.net>
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

# This script bootstraps Chef on the bootstrap node.

# NOTE: MUST execute from VAGRANT directory of project

# Fail if any issues occur...
set -e

source vagrant_base.sh

# TODO: Make OS check here to do for Ubuntu or RHEL based...
do_on_node $CEPH_CHEF_BOOTSTRAP "sudo rpm -Uvh \$(find /ceph-files/ -name chef-server\*rpm -not -name \*downloaded | tail -1)"

do_on_node $CEPH_CHEF_BOOTSTRAP "sudo sh -c \"echo nginx[\'non_ssl_port\'] = 4000 > /etc/opscode/chef-server.rb\""
do_on_node $CEPH_CHEF_BOOTSTRAP "sudo chef-server-ctl reconfigure"
do_on_node $CEPH_CHEF_BOOTSTRAP "sudo chef-server-ctl user-create admin admin admin admin@localhost.com welcome --filename /etc/opscode/admin.pem"
do_on_node $CEPH_CHEF_BOOTSTRAP "sudo chef-server-ctl org-create ceph ceph --association admin --filename /etc/opscode/ceph-validator.pem"
do_on_node $CEPH_CHEF_BOOTSTRAP "sudo chmod 0644 /etc/opscode/admin.pem /etc/opscode/ceph-validator.pem"

# configure knife on the ceph-bootstrap node and perform a knife ceph-bootstrap to create the ceph-bootstrap node in Chef
do_on_node $CEPH_CHEF_BOOTSTRAP "mkdir -p \$HOME/.chef && echo -e \"chef_server_url 'https://$CEPH_CHEF_BOOTSTRAP.$BOOTSTRAP_DOMAIN/organizations/ceph'\\\nvalidation_client_name 'ceph-validator'\\\nvalidation_key '/etc/opscode/ceph-validator.pem'\\\nnode_name 'admin'\\\nclient_key '/etc/opscode/admin.pem'\\\nknife['editor'] = 'vim'\\\ncookbook_path [ \\\"#{ENV['HOME']}/chef-bcs/cookbooks\\\" ]\" > \$HOME/.chef/knife.rb"
do_on_node $CEPH_CHEF_BOOTSTRAP "$KNIFE ssl fetch"

if [ -n "$CEPH_CHEF_HTTP_PROXY" ];
then
  KNIFE_HTTP_PROXY_PARAM="--bootstrap-proxy \$http_proxy"
fi

# NOTE: If this command seems to stall then the network needs to be reset. Run ./vagrant_reset_network.sh from the
# directory this script is located in. This will clean any network issues. Same holds true for other VMs.
do_on_node $CEPH_CHEF_BOOTSTRAP "$KNIFE bootstrap -x vagrant --bootstrap-no-proxy '$CEPH_CHEF_BOOTSTRAP.$BOOTSTRAP_DOMAIN' $KNIFE_HTTP_PROXY_PARAM -P vagrant --sudo $CEPH_CHEF_BOOTSTRAP_IP"

# install the knife-acl plugin into embedded knife
do_on_node $CEPH_CHEF_BOOTSTRAP "sudo /opt/opscode/embedded/bin/gem install /ceph-files/gems/knife-acl-0.0.12.gem"

do_on_node $CEPH_CHEF_BOOTSTRAP "cd \$HOME && rsync -a /ceph-host/* ./chef-bcs"

# add the dependency cookbooks from the file cache
echo "Checking on dependency for cookbooks..."
do_on_node $CEPH_CHEF_BOOTSTRAP "cp /ceph-files/cookbooks/*.tar.gz \$HOME/chef-bcs/cookbooks"
do_on_node $CEPH_CHEF_BOOTSTRAP "cd \$HOME/chef-bcs/cookbooks && ls -1rtc *.tar.gz | xargs -t -I% tar xvzf %"
do_on_node $CEPH_CHEF_BOOTSTRAP "cd \$HOME/chef-bcs/cookbooks && rm -f *.tar.gz"

# NOTE: *HAVE* to load the files into files/ before cookbook upload
if [[ ! -z $COBBLER_BOOTSTRAP_ISO ]]; then
  do_on_node $CEPH_CHEF_BOOTSTRAP "sudo cp /ceph-files/cobbler/loaders/* \$HOME/chef-bcs/cookbooks/chef-bcs/files/loaders"
  do_on_node $CEPH_CHEF_BOOTSTRAP "sudo rm -f \$HOME/chef-bcs/cookbooks/chef-bcs/files/loaders/*_downloaded"
fi

# Add chef info to boostrap node.
do_on_node $CEPH_CHEF_BOOTSTRAP "$KNIFE cookbook upload -a"
do_on_node $CEPH_CHEF_BOOTSTRAP "cd \$HOME/chef-bcs/roles && $KNIFE role from file *.json"
do_on_node $CEPH_CHEF_BOOTSTRAP "cd \$HOME/chef-bcs/environments && $KNIFE environment from file $BOOTSTRAP_CHEF_ENV.json"
