#!/bin/bash
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

# Exit immediately if anything goes wrong!
set -eu

# Check for required environment variables and exit if not all are set.
FAILED_ENVVAR_CHECK=0
REQUIRED_VARS=( BOOTSTRAP_CACHE_DIR BOOTSTRAP_OS )
for ENVVAR in ${REQUIRED_VARS[@]}; do
  if [[ -z ${!ENVVAR} ]]; then
    echo "Environment variable $ENVVAR must be set!" >&2
    FAILED_ENVVAR_CHECK=1
  fi
done
if [[ $FAILED_ENVVAR_CHECK != 0 ]]; then exit 1; fi

# Create directory for download cache.
mkdir -p $BOOTSTRAP_CACHE_DIR/cobbler/{isos,loaders}
mkdir -p $BOOTSTRAP_CACHE_DIR/python
mkdir -p $BOOTSTRAP_CACHE_DIR/rpms

# download_file wraps the usual behavior of curling a remote URL to a local file
# NOTE: PROXY - Make sure your http_proxy and https_proxy envrionment variables are set correctly if behind a proxy.
download_file() {
  FILE=$1
  URL=$2

  if [[ ! -f $BOOTSTRAP_CACHE_DIR/$FILE && ! -f $BOOTSTRAP_CACHE_DIR/${FILE}_downloaded ]]; then
    echo $FILE
    echo $URL
    rm -f $BOOTSTRAP_CACHE_DIR/$FILE
    curl -L --progress-bar -o $BOOTSTRAP_CACHE_DIR/$FILE $URL
    touch $BOOTSTRAP_CACHE_DIR/${FILE}_downloaded
  fi
}

# NOTE: PROXY - Make sure your ftp_proxy envrionment variable is set correctly if behind a proxy.
ftp_file() {
  FILE=$1
  URL=$2

  if [[ ! -f $BOOTSTRAP_CACHE_DIR/$FILE && ! -f $BOOTSTRAP_CACHE_DIR/${FILE}_downloaded ]]; then
    echo $FILE
    echo $URL
    rm -f $BOOTSTRAP_CACHE_DIR/$FILE
    wget $URL -O $BOOTSTRAP_CACHE_DIR/$FILE
    touch $BOOTSTRAP_CACHE_DIR/${FILE}_downloaded
  fi
}

git_clone_or_update() {
  local NAME=$1
  local URL=$2

  echo "Git clone or update..."
  if [[ ! -f $BOOTSTRAP_CACHE_DIR/${NAME}_downloaded ]]; then
    if [[ ! -d $BOOTSTRAP_CACHE_DIR/$NAME ]]; then
      git clone $URL $BOOTSTRAP_CACHE_DIR/$NAME || true
    else
      ( cd $BOOTSTRAP_CACHE_DIR/$NAME && git pull --ff-only $URL )
    fi
    touch $BOOTSTRAP_CACHE_DIR/${NAME}_downloaded
  fi
}

# Obtain an RHEL 7.2 image to be used for PXE booting in production.
echo "Downloading ISO..."
if [[ ! -z $COBBLER_BOOTSTRAP_ISO ]]; then
  if [[ $COBBLER_DOWNLOAD_ISO -eq 1 ]]; then
    # NOTE: the +e is because the hardware build. We can change it later...
    set +e
    download_file cobbler/isos/$COBBLER_BOOTSTRAP_ISO $COBBLER_REMOTE_URL_ISO
    set -e
  fi
fi

if [[ ! -z $COBBLER_BOOTSTRAP_ISO ]]; then
  download_file cobbler/loaders/pxelinux.0 http://cobbler.github.io/loaders/pxelinux.0-3.86
  download_file cobbler/loaders/menu.c32 http://cobbler.github.io/loaders/menu.c32-3.86
  download_file cobbler/loaders/grub-x86.efi http://cobbler.github.io/loaders/grub-0.97-x86.efi
  download_file cobbler/loaders/grub-x86_64.efi http://cobbler.github.io/loaders/grub-0.97-x86_64.efi
fi

# Obtain Chef client and server RPMs.
# export CHEF_CLIENT_RPM=chef-12.18.31-1.el7.x86_64.rpm
# export CHEF_CLIENT_RPM_SEMVER=12.18.31
# export CHEF_SERVER_RPM=chef-server-core-12.11.1-1.el7.x86_64.rpm
# export CHEF_SERVER_RPM_SEMVER=12.11.1
export CHEF_CLIENT_RPM=chef-12.19.36-1.el7.x86_64.rpm
export CHEF_CLIENT_RPM_SEMVER=12.19.36
export CHEF_SERVER_RPM=chef-server-core-12.13.0-1.el7.x86_64.rpm
export CHEF_SERVER_RPM_SEMVER=12.13.0
echo "Downloading Chef..."
download_file /rpms/$CHEF_CLIENT_RPM https://packages.chef.io/files/stable/chef/$CHEF_CLIENT_RPM_SEMVER/el/7/$CHEF_CLIENT_RPM
download_file /rpms/$CHEF_SERVER_RPM https://packages.chef.io/files/stable/chef-server/$CHEF_SERVER_RPM_SEMVER/el/7/$CHEF_SERVER_RPM
# BIRD is a little different :)
#ftp_file /rpms/bird-1.5.0-1.x86_64.rpm ftp://bird.network.cz/pub/bird/redhat/bird-1.5.0-1.x86_64.rpm

# Python pyyaml - previous 3.11
download_file /python/PyYAML-3.12.tar.gz http://pyyaml.org/download/pyyaml/PyYAML-3.12.tar.gz

# Pull needed *cookbooks* from the Chef Supermarket.
mkdir -p $BOOTSTRAP_CACHE_DIR/{cookbooks,gems}

# Most important cookbook
# If set then it will not download but remove from cache and use the development version that should be set in the chef-bcs/cookbooks directory.
if [[ $CHEF_BCS_DEBUG -eq 0 ]]; then
  echo "Downloading ceph-chef..."
  download_file cookbooks/ceph-chef-1.1.8.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/ceph-chef/versions/1.1.8/download
else
  # Remove it so it's not used.
  rm -f $BOOTSTRAP_CACHE_DIR/cookbooks/ceph-chef-*
fi

if [[ $CEPH_DEV_MODE -ne 0 ]]; then
  echo "Cloning Ceph..."
  git_clone_or_update github/ceph https://github.com/ceph/ceph.git
fi

# previous poise-2.6.0
download_file cookbooks/poise-2.7.2.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/poise/versions/2.7.2/download
# previous chef-client-4.3.3
download_file cookbooks/chef-client-7.2.0.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/chef-client/versions/7.2.0/download
# previous windows-1.39.1
download_file cookbooks/windows-2.1.1.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/windows/versions/2.1.1/download
# previous ohai-5.0.0 (dependency of windows)
download_file cookbooks/ohai-5.0.0.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/ohai/versions/5.0.0/download
# previous cron-4.0.0
download_file cookbooks/cron-4.1.0.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/cron/versions/4.1.0/download
# previous logrotate-1.9.2
download_file cookbooks/logrotate-2.1.0.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/logrotate/versions/2.1.0/download
# previous compat_resource-12.16.3 (dependency for logrotate)
download_file cookbooks/compat_resource-12.16.3.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/compat_resource/versions/12.16.3/download
# previous ntp-1.10.1
download_file cookbooks/ntp-3.3.1.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/ntp/versions/3.3.1/download
# previous yum-3.10.0
download_file cookbooks/yum-5.0.0.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/yum/versions/5.0.0/download
# previous yum-epel.0.6.5
download_file cookbooks/yum-epel.2.1.1.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/yum-epel/versions/2.1.1/download
# previous apt-1.10.0
download_file cookbooks/apt-6.0.1.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/apt/versions/6.0.1/download
# previous apache2-3.1.0
download_file cookbooks/apache2-3.2.2.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/apache2/versions/3.2.2/download
# previous chef_handler-1.3.0
download_file cookbooks/chef_handler-2.1.0.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/chef_handler/versions/2.1.0/download
# previous firewall-2.4.0
download_file cookbooks/firewall-2.5.4.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/firewall/versions/2.5.4/download
# previous chef-sugar-3.4.0
download_file cookbooks/chef-sugar-3.4.0.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/chef-sugar/versions/3.4.0/download
# previous sudo-2.9.0
download_file cookbooks/sudo-3.3.1.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/sudo/versions/3.3.1/download
# previous collectd-2.2.2
download_file cookbooks/collectd-2.2.4.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/collectd/versions/2.2.4/download
# previous collectd_plugins-2.1.1
download_file cookbooks/collectd_plugins-2.1.3.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/collectd_plugins/versions/2.1.3/download
# previous poise-service-1.0.0
download_file cookbooks/poise-service-1.4.2.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/poise-service/versions/1.4.2/download

# For yum groupinstalls. Used to help install dev/test environment
# previous yumgroup-0.5.0
download_file cookbooks/yumgroup-0.5.0.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/yumgroup/versions/0.5.0/download

# Could download development packages if desired and needed behind firewalls. It would ge here...

# Gems
# REQUIRED for ceph-chef cookbook - must be installed before doing 'sudo chef-client' on any node
# previous netaddr-1.5.1
download_file gems/netaddr-1.5.1.gem https://rubygems.org/downloads/netaddr-1.5.1.gem
# previous chef-sugar-3.4.0
download_file gems/chef-sugar-3.4.0.gem https://rubygems.org/downloads/chef-sugar-3.4.0.gem

# Pull knife-acl gem. This is ONLY needed if using data bags where the data bag is created with a recipe!
# 0.0.12
# previous knife-acl-0.0.12
download_file gems/knife-acl-0.0.12.gem https://rubygems.global.ssl.fastly.net/gems/knife-acl-0.0.12.gem

# Pull needed gems for fpm
GEMS=( arr-pm-0.0.10 backports-3.6.4 cabin-0.7.1 childprocess-0.5.6 clamp-0.6.5 ffi-1.9.8 fpm-1.3.3 json-1.8.2 )
mkdir -p $BOOTSTRAP_CACHE_DIR/gems
for GEM in ${GEMS[@]}; do
  download_file gems/$GEM.gem https://rubygems.global.ssl.fastly.net/gems/$GEM.gem
done
