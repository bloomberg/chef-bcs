## Cookbooks

The default cookbook here is the

**chef-bcs**

Other cookbooks will be automatically copied here via the bash script called **bootstrap_prereqs.sh** found in the **[chef-bcs-root-dir]/bootstrap/common** directory.

The most important cookbook that will be copied here is the

**ceph-chef**

 cookbook found at https://github.com/ceph/ceph-chef. This cookbook contains *ALL* of the Ceph related recipes that will install, remove and manage your Ceph clusters.

All of the other cookbooks are dependencies for chef-bcs and ceph-chef. A full list of the dependencies can be found in the **metadata.rb** in this directory.

To get a better overview of the overall project, check out the README.md in the root of this repo.
