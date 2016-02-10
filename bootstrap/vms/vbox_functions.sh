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

# Exit immediately if anything goes wrong, instead of making things worse.
set -e

# Set the base directory. This will also get set again later which is ok.
export REPO_ROOT=$(git rev-parse --show-toplevel)

source $REPO_ROOT/bootstrap/vms/base_environment.sh
source $REPO_ROOT/bootstrap/common/bash_functions.sh

# NOTE: These VirtualBox functions are purpose built for chef-bcs and not generic vbox functions.
# However, they can be modified with parameter passing to make more generic.

function vbox_dir {
  echo $(vboxmanage list systemproperties | grep 'Default machine folder' | awk -F\: '{gsub(/^[ \t]+/, "", $2); print $2}')
}

# NOTE: Additional parameters could be passed to customize if desired.
function vbox_create {
  local vm=$1
  local ostype=RedHat_64
  # ostype for Ubuntu - Ubuntu_64
  vm_dir=$(vbox_dir)
  echo $vm
  echo $vm_dir
  echo $ostype

  # NOTE: Modify memory, vram, cpus etc below if desired.
  if [[ `is_vm_present $vm` -eq 0 ]]; then
    echo $(vboxmanage createvm --name $vm --ostype $ostype 2>/dev/null)
    echo $(vboxmanage registervm "$vm_dir/$vm/$vm.vbox")
    echo $(vboxmanage modifyvm $vm --ioapic on --memory 2560 --vram 16 --cpus 2 --largepages on --nestedpaging on --vtxvpid on --hwvirtex on  2>/dev/null)
  fi
}

# Set the vm's boot order
function vbox_boot_order {
  local vm=$1
  local order=$2
  local type=$3
  # vm and order must be valid!
  # order can be slot index is 1,2,3,4
  # type can be none|floppy|dvd|disk|net
  echo $(vboxmanage modifyvm $vm --boot$order $type 2>/dev/null)
}

# Set which nic boot order for pxe
# For Ceph this should be the 'public' cluster nic unless using a mgt interface
function vbox_nic_boot_order {
  local vm=$1
  local nic=$2
  local priority=$3
  # nic is slot index is 1,2,3,4...
  # priority 0 - lowest (default), 1 (highest), 2, 3, 4 (low)

  echo $(vboxmanage modifyvm $vm --nicbootprio$nic $priority 2>/dev/null)
}

# Set the mac address
function vbox_nic_mac_set {
  local vm=$1
  local nic=$2
  local mac=$3
  # nic is slot index is 1,2,3,4...
  # mac address

  echo $(vboxmanage modifyvm $vm --macaddress$nic $mac 2>/dev/null)
}

# Get the mac address from the vm and adapter (vboxnet0...)
function vbox_nic_mac_get {
  local vm=$1
  local adapter=$2
  # nic is slot index is 1,2,3,4...
  echo $(vboxmanage showvminfo --machinereadable $vm | pcregrep -o1 -M '^hostonlyadapter\d="$adapter"$\n*^macaddress\d="(.+)"' | $SED 's/^(..)(..)(..)(..)(..)(..)$/\1:\2:\3:\4:\5:\6/' 2>/dev/null)
}

function vbox_create_storage_controller {
  local vm=$1
  local controller="$2"

  # 5 ports - could be whatever you want as long as there are enough ports of the number of drives.
  echo $(vboxmanage storagectl $vm --name "$controller" --add sata --bootable on --controller IntelAhci --portcount 5 2>/dev/null)
}

function vbox_remove_hdd {
  local vm=$1
  local controller="$2"
  local dev=$3
  local port=$4

  echo "remove_hdd - $vm, $controller, $dev, $port"

  echo $(vboxmanage storageattach $vm --storagectl "$controller" --device $dev --port $port --medium none 2>/dev/null)
}

function vbox_delete_hdd {
  local vm=$1
  local controller="$2"
  local dev=$3
  local port=$4
  local disk_file="$5"

  echo "delete_hdd - $vm, $controller, $dev, $port, $disk_file"

  vbox_remove_hdd $vm "$controller" $dev $port
  echo $(rm -f "$disk_file" 2>/dev/null)
}

function vbox_add_hdd {
  local vm=$1
  local controller="$2"
  local dev=$3
  local port=$4
  local disk_file="$5"

  echo "add_hdd - $vm, $controller, $dev, $port, $disk_file"

  echo $(vboxmanage storageattach $vm --storagectl "$controller" --device $dev --port $port --type hdd --medium "$disk_file" 2>/dev/null)
}

function vbox_create_hdd {
  local disk_file="$1"
  local size=$2

  echo "create_hdd - $vm, $disk_file"

  echo $(vboxmanage createhd --filename "$disk_file" --size $size 2>/dev/null)
}

function add_shared_folder_to_vm {
    local vm=$1
    local name=$2
    local path=$3
    if [[ `is_vm_running $vm` -eq 1 ]]; then
        del_shared_folder_from_vm $vm $name
        VBoxManage sharedfolder add $vm --name "$name" --hostpath "$path" --transient
    fi
}

function del_shared_folder_from_vm {
    local vm=$1
    local name=$2
    if [[ `is_vm_running $vm` -eq 1 ]]; then
        VBoxManage sharedfolder remove $vm --name "$name" --transient 2>/dev/null
    fi
}

################################################################################
# Function to remove VirtualBox DHCP servers
# By default, checks for any DHCP server on networks without VM's & removes them
# (expecting if a remove fails the function should bail)
# If a network is provided, removes that network's DHCP server
# (or passes the vboxmanage error and return code up to the caller)
#
function remove_DHCPservers {
  local network_name=${1-}
  if [[ -z "$network_name" ]]; then
    # make a list of VM UUID's
    local vms=$(VBoxManage list vms|sed 's/^.*{\([0-9a-f-]*\)}/\1/')
    # make a list of networks (e.g. "vboxnet0 vboxnet1")
    local vm_networks=$(for vm in $vms; do \
      VBoxManage showvminfo --details --machinereadable $vm | \
      grep -i '^hostonlyadapter[2-9]=' | \
      sed -e 's/^.*=//' -e 's/"//g'; \
    done | sort -u)
    # will produce a regular expression string of networks which are in use by VMs
    # (e.g. ^vboxnet0$|^vboxnet1$)
    local existing_nets_reg_ex=$(sed -e 's/^/^/' -e 's/$/$/' -e 's/ /$|^/g' <<< "$vm_networks")

    VBoxManage list dhcpservers | grep -E "^NetworkName:\s+HostInterfaceNetworking" | awk '{print $2}' |
    while read -r network_name; do
      [[ -n $existing_nets_reg_ex ]] && ! egrep -q $existing_nets_reg_ex 2> /dev/null <<< $network_name && continue
      remove_DHCPservers $network_name
    done
  else
    VBoxManage dhcpserver remove --netname "$network_name" && local return=0 || local return=$?
    return $return
  fi
}

# Make sure remove_DHCPservers is ran before this
function create_network_interfaces {
    for i in 0 1 2 3 4 5 6 7 8 9; do
        if [[ ! -z `VBoxManage list hostonlyifs | grep vboxnet$i | cut -f2 -d" "` ]]; then
          VBoxManage hostonlyif remove vboxnet$i || true
        fi
    done

    # Force nics to the default "none"
    for vm in ${CEPH_CHEF_HOSTS[@]}; do
        VBoxManage modifyvm $vm --nic2 none
        VBoxManage modifyvm $vm --nic3 none
        # VBoxManage modifyvm $vm --nic4 none
    done

    # Create 2 interfaces
    VBoxManage hostonlyif create
    VBoxManage hostonlyif create
    # VBoxManage hostonlyif create

    # NOTE: Later, cycle through hostonlyifs and if found with IPs below then just use those vboxnet_

    # Set the interface up and default gateway
    VBoxManage hostonlyif ipconfig vboxnet0 --ip ${CEPH_CHEF_ADAPTERS[0]} --netmask ${CEPH_CHEF_ADAPTERS[2]}
    VBoxManage hostonlyif ipconfig vboxnet1 --ip ${CEPH_CHEF_ADAPTERS[1]} --netmask ${CEPH_CHEF_ADAPTERS[2]}
    # VBoxManage hostonlyif ipconfig vboxnet2 --ip ${CEPH_CHEF_ADAPTERS[2]} --netmask ${CEPH_CHEF_ADAPTERS[3]}

    # Since VirtualBox created the vms the default for nic1 is nat so no need to modify here
    for vm in ${CEPH_CHEF_HOSTS[@]}; do
        VBoxManage modifyvm $vm --nic2 hostonly --hostonlyadapter2 vboxnet0
        VBoxManage modifyvm $vm --nic3 hostonly --hostonlyadapter3 vboxnet1
        # VBoxManage modifyvm $vm --nic4 hostonly --hostonlyadapter4 vboxnet2
        # Set to server nic
        VBoxManage modifyvm $vm --nictype2 82543GC
        VBoxManage modifyvm $vm --nictype3 82543GC
        # VBoxManage modifyvm $vm --nictype4 82543GC
    done
}

###################################################################
# Function to configure all of the networks for the vms
function config_networks {
    # Force a pause to allow all of the vms to settle
    echo "Preparing to shutdown VMs. Please wait..."
    sleep 5

    source $REPO_ROOT/bootstrap/vms/ceph_chef_hosts.env
    source $REPO_ROOT/bootstrap/vms/ceph_chef_adapters.env
    source $REPO_ROOT/bootstrap/vms/ceph_chef_bootstrap.env

    echo "Gracefully shutting down VMs to install adapters. Please wait..."
    shutdown_vms

    # If you don't give VB enough time to close things down it will corrupt
    echo "Creating network interfaces..."
    sleep 3

    # Build interfaces...
    create_network_interfaces

    # IMPORTANT
    # Create OSD drives and attach them
    source $REPO_ROOT/bootstrap/vms/vbox_attach_osd_drives.sh

    # start
    echo "Restarting VMs. Please wait..."
    start_vms

    # Force a pause to allow for spin up
    echo "Updating IPs on network interfaces..."
    sleep 10
    update_network_interfaces

    echo "Completed IP assignments..."

    export BOOTSTRAP_LAST_COMPLETE=3
}

function shutdown_vms {
    for vm in ${CEPH_CHEF_HOSTS[@]}; do
        if [[ `is_vm_running $vm` -eq 1 ]]; then
            VBoxManage controlvm $vm acpipowerbutton  # poweroff caused issues so use acpipowerbutton instead
            echo "Shutting down $vm"
            sleep 3
        fi
    done
}

function start_vms {
    for vm in ${CEPH_CHEF_HOSTS[@]}; do
        if [[ `is_vm_running $vm` -ne 1 ]]; then
            VBoxManage startvm $vm --type headless
            echo "Starting $vm"
            sleep 3
        fi
    done
}

function delete_vm {
    local vm=$1
    if [[ `is_vm_present $vm` -eq 1 ]]; then
        VBoxManage unregistervm $vm --delete 2>/dev/null
    fi
}

function is_vm_running {
    local vm=$1
    local state=$(VBoxManage showvminfo $vm --details --machinereadable 2>/dev/null | grep "^VMState=" | cut -d= -f2)
    if [[ "$state" = "\"running\"" ]]; then
        echo 1
    else
        echo 0
    fi
}

function is_vm_present {
    local vm=$(VBoxManage list vms | grep "\"$1\"")
    if [[ ! -z $vm ]]; then
        echo 1
    else
        echo 0
    fi
}

function get_vm_ssh_port {
    local vm=$1
    local port=$(VBoxManage showvminfo $vm --machinereadable | grep ssh | cut -d= -f2 | cut -d, -f4)
    echo $port
}

function clone_vms {
    echo "Cloning VMs. Please wait..."
    # For now - remove via VirtualBox UI and double check where VirtualBox VMs are located on host machine
    # Remove existing clones if present
    #for vm in ${CEPH_CHEF_HOSTS[@]}; do
    #    if [[ `is_vm_present $vm-clone` -eq 1 ]]; then
    #        VBoxManage unregistervm $vm-clone --delete 2>/dev/null
    #    fi
    #done

    # clone - Note: Do not register clones. They will not show up in the VirtualBox UI unless registered (so don't register)
    for vm in ${CEPH_CHEF_HOSTS[@]}; do
        # removed --register from clonevm cli
        VBoxManage clonevm $vm --name $vm-clone --mode all --options keepdisknames  # --options keepallmacs  #keepdisknames
        echo "Clone: $vm-clone is now available and powered off."
    done
}

function make_clones_active_vms {
    echo "Making cloned VMs active. Please wait..."
    echo "Unregistering VMs..."
    set +e
    for vm in ${CEPH_CHEF_HOSTS[@]}; do
      if [[ `is_vm_present $vm` -eq 1 ]]; then
          VBoxManage unregistervm $vm --delete 2>/dev/null
          echo "Unregistered $vm"
      fi
    done
    set -e

    echo "Copying clone and registering VMs..."
    # reverse clone
    vm_dir=$(vbox_dir)
    echo "$vm_dir"
    for vm in ${CEPH_CHEF_HOSTS[@]}; do
      # We only want the clone registered so that it can "clone" as the original and then unregister again.
      VBoxManage registervm "$vm_dir/$vm-clone/$vm-clone.vbox"
      VBoxManage clonevm $vm-clone --name $vm --register --mode all --options keepdisknames
      VBoxManage unregistervm $vm-clone
      echo "Activating: $vm from clone. It is now available and powered off."
    done
}
