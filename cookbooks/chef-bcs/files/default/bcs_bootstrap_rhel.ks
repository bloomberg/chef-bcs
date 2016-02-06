# Static for a given environment
#
# kickstart file for Chef-BCS Bootstrap
#

########## MODIFY SECTION ##########
# To create encrypted pwd: python -c 'import crypt; print(crypt.crypt("password", "$6$My Salt"))'
# Change 'password' to whatever password you like.

# Root password
# rootpw --iscrypted $default_password_crypted
# Simple clear text pwd for boot but changes once installed. You can also generate an encrypted pwd and put it here
rootpw --plaintext password

# User
# Simple clear text pwd for boot but changes once installed. You can also generate an encrypted pwd and put it here
user --plaintext --name=operations --password=password

# Static NETWORK
network --bootproto=static --device=enp0s3 --noipv6 --activate --ip=10.0.101.10 --netmask=255.255.255.0 --gateway=10.0.101.10 --nameserver=8.8.8.8 --hostname=vbox-ceph-bootstrap
network --bootproto=static --device=enp0s8 --noipv6 --activate --ip=192.168.101.10 --netmask=255.255.255.0

# Important: The bootstrap partition schema is static to the given environment
# ignoredisk --drives=sdb,sdc
ignoredisk --only-use=sda
part /boot    --fstype=xfs --size=1024   --ondisk=sda
part /        --fstype=xfs --size=10000  --ondisk=sda
part /var/lib --fstype=xfs --size=20000  --ondisk=sda
part swap                  --size=8000
# part swap                  --size=32768

####################################
# Bootstrap installs from mounted iso, not netboot like nodes kickstart
cdrom

# Install OS instead of upgrade
install

# System authorization information
auth  --useshadow  --enablemd5

# System bootloader configuration
bootloader --location=mbr

# Partition clearing information
clearpart --all --initlabel

# Use text mode install
text

# Firewall configuration
firewall --disable

# Run the Setup Agent on first boot
firstboot --disable

# System keyboard
keyboard us

# System language
lang en_US

# If any cobbler repo definitions were referenced in the kickstart profile, include them here.
$yum_repo_stanza

# Reboot after installation
reboot

# SELinux configuration
selinux --disabled

# Do not configure the X Window System
skipx

# System timezone
timezone UTC --isUtc

# Clear the Master Boot Record
zerombr

%pre
$SNIPPET('log_ks_pre')
$SNIPPET('autoinstall_start')
$SNIPPET('pre_install_network_config')
# Enable installation monitoring
$SNIPPET('pre_anamon')
%end

%packages
@Infrastructure Server
wget
curl
ntp
tftp-server
dnsmasq
%end

%post --nochroot
$SNIPPET('log_ks_post_nochroot')

#!/bin/sh

set -x -v
exec 1>/mnt/sysimage/root/kickstart-stage1.log 2>&1

echo "==> copying files from media to install drive..."
cp -r /run/install/repo/postinstall /mnt/sysimage/root
%end


%post
$SNIPPET('log_ks_post')
# Start yum configuration
$yum_config_stanza
# End yum configuration

$SNIPPET('post_install_kernel_options')
$SNIPPET('post_install_network_config')
$SNIPPET('download_config_files')
$SNIPPET('koan_environment')
$SNIPPET('redhat_register')
$SNIPPET('cobbler_register')
# Enable post-install boot notification
$SNIPPET('post_anamon')

# Start final steps
# Allow root login to begin with. Chef recipe will disable later in process.
sed -i "s/#PermitRootLogin yes/PermitRootLogin yes/" /etc/ssh/sshd_config
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
mkdir -p /root/.ssh
# Add a public key here if you like to authorized_keys but make sure to set permission to 0600

# Setup sudoer
echo "%operations %> ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/operations
sed -i "s/^[^#].*requiretty/#Defaults requiretty/" /etc/sudoers

# Sets the --netboot flag for the host on cobbler
$SNIPPET('kickstart_done')
# End final steps
%end
