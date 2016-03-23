name 'chef-bcs'
maintainer 'Chris Jones'
maintainer_email 'cjones303@bloomberg.net'
license 'Apache v2.0'
description 'Installs/Configures chef-bcs'
long_description 'Installs/Configures chef-bcs - requires github.com/ceph/ceph-chef'
version '0.9.9'

depends "chef-client", ">= 2.2.2"
depends "cron", ">= 1.7.4"
depends "ntp", ">= 1.10.0"
depends "ceph-chef", ">= 0.9.3"
# depends "firewall", ">= 2.4"
depends "sudo", ">= 2.7.2"

supports 'redhat', '>= 7.1'
supports 'centos', '>= 7.1'

issues_url 'https://github.com/bloomberg/chef-bcs/issues'
source_url 'https://github.com/bloomberg/chef-bcs'
