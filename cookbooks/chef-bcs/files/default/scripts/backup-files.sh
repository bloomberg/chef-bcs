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
# NOTE: Make sure DATE does not have any ':' characters
DATE=$2

# Change this to whatever user you want or put into a template later...
USER=operations

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
  mkdir -p /home/$USER/chef-bcs-backups/chef-bcs-$VERSION-$DATE/ceph/etc/ceph

  # Backup /etc/ceph configs and keys
  sudo cp /etc/ceph/* /home/$USER/chef-bcs-backups/chef-bcs-$VERSION-$DATE/ceph/etc/ceph

  # Backup keys in /var/lib/ceph
  for i in $(sudo find /var/lib/ceph -name keyring); do
    new_dir=${i%keyring}
    mkdir -p /home/$USER/chef-bcs-backups/chef-bcs-$VERSION-$DATE/ceph/$new_dir
    sudo cp $i /home/$USER/chef-bcs-backups/chef-bcs-$VERSION-$DATE/ceph$i
  done

  # Get crushmap and back it up
  ceph osd getcrushmap -o /home/$USER/chef-bcs-backups/chef-bcs-$VERSION-$DATE/ceph/crushmap.out
  crushtool -d /home/$USER/chef-bcs-backups/chef-bcs-$VERSION-$DATE/ceph/crushmap.out -o /home/$USER/chef-bcs-backups/chef-bcs-$VERSION-$DATE/ceph/crushmap.txt

  logger -t BCSBackup "Backed up Ceph files - $VERSION-$DATE"
fi

# Bird
if [[ -f /etc/bird.conf ]]; then
  mkdir -p /home/$USER/chef-bcs-backups/chef-bcs-$VERSION-$DATE/bird/etc
  sudo cp /etc/bird.conf /home/$USER/chef-bcs-backups/chef-bcs-$VERSION-$DATE/bird/etc

  logger -t BCSBackup "Backed up Bird files - $VERSION-$DATE"
fi

# HAProxy
if [[ -d /etc/haproxy ]]; then
  mkdir -p /home/$USER/chef-bcs-backups/chef-bcs-$VERSION-$DATE/haproxy/etc/haproxy
  sudo cp /etc/haproxy/* /home/$USER/chef-bcs-backups/chef-bcs-$VERSION-$DATE/haproxy/etc/haproxy

  # Get certs if any
  if [[ -d /etc/ssl/private ]]; then
    mkdir -p /home/$USER/chef-bcs-backups/chef-bcs-$VERSION-$DATE/haproxy/etc/ssl/private
    sudo cp /etc/ssl/private/* /home/$USER/chef-bcs-backups/chef-bcs-$VERSION-$DATE/haproxy/etc/ssl/private
  fi

  logger -t BCSBackup "Backed up HAProxy files - $VERSION-$DATE"
fi

# KeepAliveD
if [[ -d /etc/keepalived ]]; then
  mkdir -p /home/$USER/chef-bcs-backups/chef-bcs-$VERSION-$DATE/keepalived/etc/keepalived
  sudo cp /etc/keepalived/* /home/$USER/chef-bcs-backups/chef-bcs-$VERSION-$DATE/keepalived/etc/keepalived

  logger -t BCSBackup "Backed up KeepAliveD files - $VERSION-$DATE"
fi

# Tar up directory
sudo tar -cjf /home/$USER/chef-bcs-backups/chef-bcs-$VERSION-$DATE.tar.bz2 /home/$USER/chef-bcs-backups/chef-bcs-$VERSION-$DATE

# No longer need directory once tar
sudo rm -rf home/$USER/chef-bcs-backups/chef-bcs-$VERSION-$DATE

# Rsync/scp
