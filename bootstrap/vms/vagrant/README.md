## Important

Start:
Simply call ./VAGRANT_UP in this directory to start the build process.

Possible issues and work arounds
Vagrant plugins:
 vagrant-vbguest - This plugin is suppose to automatically upgrade your virtualbox guest additions but if the version of VirtualBox Guest Additions you have installed is more current than the version the OS 'box' version then the plugin can cause vagrant to fail.

 To check to see if the plugin is installed then do the following:
  vagrant plugin list
 If the 'vagrant-vbguest' shows then remove it as follows:
  vagrant plugin uninstall vagrant-vbguest
 Now rerun ./VAGRANT_UP in the <chef-bcs root>/bootstrap/vms/vagrant directory.  

Proxy:
 If you run behind a corporate proxy then you may need to make a few simple modifications to get Vagrant to work correctly. Vagrant uses it's own embedded version of 'curl' found in /opt/vagrant/embedded. There is a CA bundle there called cacert.pem. There are two ways to get it to work correctly.
 1. Get copies of your corporate .crt or .pem files and simply concat them to cacert.pem in the above directory.
 2. Create a new .pem file with *all* of the certs your firm requires combined into the one file (bundle). Then add an environment variable called CURL_CA_BUNDLE=<the name and location of the new file>
 Note: Some firms use more than one cert so make sure you have whatever is required.
 This is important so that the correct 'box' OS version gets downloaded and cached to your system.

 Proxy and cert values need to be added to the <chef-bcs root>/bootstrap/vms/environment_config.yaml so that they get added to the VMs so that the remote repos can be accessed.
 The following items in the environment_config.yaml need to be updated:
 http_proxy:
 https_proxy:
 ssl_ca_file_path:
 ssl_intermediate_file_path:
 *Note: The ssl_intermediate_file_path may not be required by your organization and thus can be left empty.
