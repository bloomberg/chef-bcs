## Chef roles
There are two roles that execute in only one pass of the chef-client, ceph-bootstrap and ceph-radosgw. The reason for this is due to the synchronization required with Ceph where the Ceph Monitors need to be functioning properly first for consistent results. Because of the unique nature of Ceph, this method allows for very flexible and clean recipes where some can be reused for normal Ceph maintenance such as stopping and starting clusters in correct order etc.

An alternative to this method is to "re-chef" nodes a second or maybe third time so that everything is eventually in sync.

The wrapper bash script sets a given node's run_list and then calls chef-client on the given node.
