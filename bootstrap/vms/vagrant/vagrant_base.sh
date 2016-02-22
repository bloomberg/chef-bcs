#!/bin/bash
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

# This is for situations where you have a partial setup on something and you want to override the default
# 'set -e' option. Put here so it's easy to see but the condition is further down after basic tests are performed.
# This allows you to pass anything in after the script in question which means you're making a decision to override
# the default of erroring out on anything that comes up such as 'already installed' etc. If nothing is passed in
# then the default is assumed.
# Note: This setting is only valid until something downstream (another script) overrides it.
ERR=$1

export BOOTSTRAP_CHEF_ENV=${BOOTSTRAP_CHEF_ENV:-"vagrant"}

source ../base_environment.sh

source $REPO_ROOT/bootstrap/vms/ceph_chef_bootstrap.env
source $REPO_ROOT/bootstrap/vms/ceph_chef_dns.env
source $REPO_ROOT/bootstrap/vms/ceph_chef_hosts.env
source $REPO_ROOT/bootstrap/vms/ceph_chef_adapters.env
source $REPO_ROOT/bootstrap/vms/ceph_chef_proxy.env
source $REPO_ROOT/bootstrap/vms/ceph_chef_osd_hosts.env
source $REPO_ROOT/bootstrap/vms/ceph_chef_mon_hosts.env
source $REPO_ROOT/bootstrap/vms/ceph_chef_rgw_hosts.env
source $REPO_ROOT/bootstrap/vms/ceph_chef_mds_hosts.env
source $REPO_ROOT/bootstrap/vms/ceph_chef_admin_hosts.env

source $REPO_ROOT/bootstrap/vms/vbox_functions.sh

FAILED_ENVVAR_CHECK=0
REQUIRED_VARS=( BOOTSTRAP_CHEF_ENV BOOTSTRAP_DOMAIN REPO_ROOT CEPH_CHEF_BOOTSTRAP CEPH_CHEF_HOSTS CEPH_OSD_HOSTS CEPH_OSD_DRIVES CEPH_MON_HOSTS CEPH_RGW_HOSTS )
for ENVVAR in ${REQUIRED_VARS[@]}; do
  if [[ -z ${!ENVVAR} ]]; then
    echo "Environment variable $ENVVAR must be set!" >&2
    FAILED_ENVVAR_CHECK=1
  fi
done
if [[ $FAILED_ENVVAR_CHECK != 0 ]]; then exit 1; fi

# Add 'set -e' check here
if [[ -z $ERR ]]; then
  set -e
else
  set +e
fi

# This script does a lot of stuff:
# - installs Chef Server on the ceph-bootstrap node
# - installs Chef client on all nodes

# It would be more efficient as something executed in one shot on each node, but
# doing it this way makes it easy to orchestrate operations between nodes. It will be
# overhauled at some point to not be Vagrant-specific.

do_on_node() {
  echo
  echo "Issuing command: vagrant ssh $1 -c ${2}"
  echo "----------------------------------------------------------------------------------------"
  NODE=$1
  shift
  COMMAND="${*}"
  vagrant ssh $NODE -c "$COMMAND"
}

cd $REPO_ROOT/bootstrap/vms/vagrant

# use Chef Server embedded knife instead of the one in /usr/bin
KNIFE=/opt/opscode/embedded/bin/knife

# Did not call the remove_array_element from bash_functions.sh here because we don't want to modify the CEPH_CHEF_HOSTS
delete=($CEPH_CHEF_BOOTSTRAP)
# All of the VMs for Ceph with the bootstrap node removed.
ceph_vms=("${CEPH_CHEF_HOSTS[@]/$delete}")

echo
echo "##########"
echo "Root: $REPO_ROOT"
echo "Chef-BCS Bootstrap: $CEPH_CHEF_BOOTSTRAP"
echo "Ceph VMs: ${ceph_vms[@]}"
echo "##########"
echo
