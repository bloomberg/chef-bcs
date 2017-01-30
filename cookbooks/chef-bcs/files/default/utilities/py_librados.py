#!/usr/bin/env python
#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
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

import rados

# This utility will be enhanced as needed. It will need to be ran from a ceph node.

cluster = rados.Rados(conffile='')  # /etc/ceph/ceph.conf', conf=dict(keyring='/etc/ceph/ceph.client.admin.keyring'))
cluster.connect()

print "Ceph (librados) version: " + str(cluster.version())

cluster.create_pool('test-me')
print "\nCeph pools:"
pools = cluster.list_pools()
for pool in pools:
    print pool

cluster_stats = cluster.get_cluster_stats()

print "\nCluster stats:"
for key, value in cluster_stats.iteritems():
    print key, value

cluster.shutdown()
