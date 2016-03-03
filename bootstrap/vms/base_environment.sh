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

export REPO_ROOT=$(git rev-parse --show-toplevel)

export BOOTSTRAP_DOMAIN=${BOOTSTRAP_DOMAIN:-"ceph.example.com"}
# Set the env info in the given environment
# NOTE: BOOTSTRAP_CHEF_ENV *MUST* be set to the correct environment (*.json) file (i.e., vagrant or production)
export BOOTSTRAP_CHEF_ENV=${BOOTSTRAP_CHEF_ENV:-}
export BOOTSTRAP_HTTP_PROXY=${BOOTSTRAP_HTTP_PROXY:-}
export BOOTSTRAP_HTTPS_PROXY=${BOOTSTRAP_HTTPS_PROXY:-}
export BOOTSTRAP_CACHE_DIR=${BOOTSTRAP_CACHE_DIR:-$HOME/.ceph-cache}
export BOOTSTRAP_REPO_MIRROR=${BOOTSTRAP_REPO_MIRROR:-}
# Default for rhel/centos - Ubuntu is SATAController
export VBOX_SATA_CONTROLLER=${VBOX_SATA_CONTROLLER:-"SATA Controller"}
# Set environment var BOOTSTRAP_OS here - default to centos-7
export BOOTSTRAP_OS=${BOOTSTRAP_OS:-"centos-7"}
# IMPORTANT: The name of the cobbler distro that must match node['chef-bcs']['cobbler']['os']['distro']

export COBBLER_BOOTSTRAP_ISO=${COBBLER_BOOTSTRAP_ISO:-"centos-7-x86_64-minimal.iso"}
export COBBLER_REMOTE_URL_ISO=${COBBLER_REMOTE_URL_ISO:-"http://mirror.umd.edu/centos/7.2.1511/isos/x86_64/CentOS-7-x86_64-Minimal-1511.iso"}
export COBBLER_DOWNLOAD_ISO=1

# Source the bootstrap configuration file if present.
BOOTSTRAP_CONFIG="$REPO_ROOT/bootstrap/common/bootstrap_config.sh"
if [[ -f $BOOTSTRAP_CONFIG ]]; then
  source $BOOTSTRAP_CONFIG
fi
