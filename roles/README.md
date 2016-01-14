## Chef roles
### Important to understand

Roles are used to define what gets installed and what order it gets installed in (simplified way of looking at it).

Ceph is different than most products when it comes to installing and setting up the environment since it has so many moving parts that have very specific dependencies and setup precedents.

To accommodate this we use roles and tags (we are looking at using policies for later releases). For example, we apply tags (can be found in the attributes files for each type [mon, osd, rgw, restapi, mds]). The nodes are tagged for whatever role they will play in the Ceph configuration. So, based on those roles we have the given recipes that are executed in a specific order because of dependencies.

The wrapper bash script sets a given node's run_list and then calls chef-client on the given node based on these roles.
