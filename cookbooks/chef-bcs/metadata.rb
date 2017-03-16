name 'chef-bcs'
maintainer 'Chris Jones'
maintainer_email 'cjones303@bloomberg.net'
license 'Apache v2.0'
description 'Installs/Configures chef-bcs'
long_description 'Installs/Configures chef-bcs - requires github.com/ceph/ceph-chef'
version '10.2.18'

depends "chef-client", ">= 2.2.2"
depends "cron", ">= 1.7.6"
depends "ntp", ">= 1.10.0"
depends "ceph-chef", ">= 1.0.18"
# depends "firewall", ">= 2.4"
depends "sudo", ">= 2.7.2"
depends "collectd", ">= 2.2.2"
depends "collectd_plugins", ">= 2.1.1"
depends "yumgroup", ">= 0.5.0"

supports 'redhat', '>= 7.2'
supports 'centos', '>= 7.2'

issues_url 'https://github.com/bloomberg/chef-bcs/issues'
source_url 'https://github.com/bloomberg/chef-bcs'
