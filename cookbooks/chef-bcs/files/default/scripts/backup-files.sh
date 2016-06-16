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

# NOTE: This file is for critical operations of Ceph and supporting products

set -e

VERSION=$1
DATE=$2

if [[ -z $VERSION ]]; then
  echo "MUST pass in a valid VERSION number."
  exit 1
fi

if [[ -z $DATE ]]; then
  echo "MUST pass in a valid DATE."
  exit 1
fi

# Make backup directories
# Ceph (NOTE: the /etc/ceph directory is on every node - even non-ceph nodes)
if [[ -f /etc/ceph/ceph.conf ]]; then
  mkdir -p $HOME/chef-bcs-backups/chef-bcs-$VERSION-$DATE/ceph/etc/ceph

  # Backup /etc/ceph configs and keys
  sudo cp /etc/ceph/* $HOME/chef-bcs-backups/chef-bcs-$VERSION-$DATE/ceph/etc/ceph

  # Backup keys in /var/lib/ceph
  for i in $(sudo find /var/lib/ceph -name keyring); do
    new_dir=${i%keyring}
    mkdir -p $HOME/chef-bcs-backups/chef-bcs-$VERSION-$DATE/ceph/$new_dir
    sudo cp $i $HOME/chef-bcs-backups/chef-bcs-$VERSION-$DATE/ceph$i
  done

  # Get crushmap and back it up
  ceph osd getcrushmap -o $HOME/chef-bcs-backups/chef-bcs-$VERSION-$DATE/ceph/crushmap.out
  crushtool -d $HOME/chef-bcs-backups/chef-bcs-$VERSION-$DATE/ceph/crushmap.out -o $HOME/chef-bcs-backups/chef-bcs-$VERSION-$DATE/ceph/crushmap.txt

  logger -t BCSBackup "Backed up Ceph files - $VERSION-$DATE"
fi

# Bird
if [[ -f /etc/bird.conf ]]; then
  mkdir -p $HOME/chef-bcs-backups/chef-bcs-$VERSION-$DATE/bird/etc
  sudo cp /etc/bird.conf $HOME/chef-bcs-backups/chef-bcs-$VERSION-$DATE/bird/etc

  logger -t BCSBackup "Backed up Bird files - $VERSION-$DATE"
fi

# HAProxy
if [[ -d /etc/haproxy ]]; then
  mkdir -p $HOME/chef-bcs-backups/chef-bcs-$VERSION-$DATE/haproxy/etc/haproxy
  sudo cp /etc/haproxy/* $HOME/chef-bcs-backups/chef-bcs-$VERSION-$DATE/haproxy/etc/haproxy

  # Get certs if any
  if [[ -d /etc/ssl/private ]]; then
    mkdir -p $HOME/chef-bcs-backups/chef-bcs-$VERSION-$DATE/haproxy/etc/ssl/private
    sudo cp /etc/ssl/private/* $HOME/chef-bcs-backups/chef-bcs-$VERSION-$DATE/haproxy/etc/ssl/private
  fi

  logger -t BCSBackup "Backed up HAProxy files - $VERSION-$DATE"
fi

# KeepAliveD
if [[ -d /etc/keepalived ]]; then
  mkdir -p $HOME/chef-bcs-backups/chef-bcs-$VERSION-$DATE/keepalived/etc/keepalived
  sudo cp /etc/keepalived/* $HOME/chef-bcs-backups/chef-bcs-$VERSION-$DATE/keepalived/etc/keepalived

  logger -t BCSBackup "Backed up KeepAliveD files - $VERSION-$DATE"
fi
