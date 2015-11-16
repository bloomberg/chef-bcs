name 'chef-bcs'
maintainer 'Chris Jones'
maintainer_email 'cjones303@bloomberg.net'
license 'Apache2'
description 'Installs/Configures chef-bcs'
long_description 'Installs/Configures chef-bcs - requires github.com/ceph/ceph-chef'
version '0.9.0'

depends "chef-client", ">= 2.2.2"
depends "cron", ">= 1.2.2"
depends "ntp", ">= 1.3.2"
depends "ceph-chef", ">= 0.9.0"
depends "firewall", ">= 2.1"
depends "sudo", ">= 2.7.2"
