#
# Cookbook Name:: chef-bcs
# Library:: utils
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

require 'openssl'
require 'base64'
require 'thread'
require 'ipaddr'

def init_config
    if not Chef::DataBag.list.key?('configs')
        Chef::Log.info("************ Creating data_bag \"configs\"")
        bag = Chef::DataBag.new
        bag.name("configs")
        bag.save
    end rescue nil
    begin
        $dbi = Chef::DataBagItem.load('configs', node.chef_environment)
        $edbi = Chef::EncryptedDataBagItem.load('configs', node.chef_environment) if node['chef-bcs']['enabled']['encrypt_data_bag']
        Chef::Log.info("============ Loaded existing data_bag_item \"configs/#{node.chef_environment}\"")
    rescue
        $dbi = Chef::DataBagItem.new
        $dbi.data_bag('configs')
        $dbi.raw_data = { 'id' => node.chef_environment }
        $dbi.save
        $edbi = Chef::EncryptedDataBagItem.load('configs', node.chef_environment) if node['chef-bcs']['enabled']['encrypt_data_bag']
        Chef::Log.info("++++++++++++ Created new data_bag_item \"configs/#{node.chef_environment}\"")
    end
end

def set_item(key, value, force=false)
    init_config if $dbi.nil?
    if $dbi[key].nil? or force
        $dbi[key] = (node['chef-bcs']['enabled']['encrypt_data_bag']) ? Chef::EncryptedDataBagItem.encrypt_value(value, Chef::EncryptedDataBagItem.load_secret) : value
        $dbi.save
        $edbi = Chef::EncryptedDataBagItem.load('configs', node.chef_environment) if node['chef-bcs']['enabled']['encrypt_data_bag']
        Chef::Log.info("++++++++++++ Creating new item with key \"#{key}\"")
        return value
    else
        Chef::Log.info("============ Loaded existing item with key \"#{key}\"")
        return (node['chef-bcs']['enabled']['encrypt_data_bag']) ? $edbi[key] : $dbi[key]
    end
end

def is_defined(key)
    init_config if $dbi.nil?
    Chef::Log.info("------------ Checking if key \"#{key}\" is defined")
    result = (node['chef-bcs']['enabled']['encrypt_data_bag']) ? $edbi[key] : $dbi[key]
    return !result.nil?
end

def get_item(key)
    init_config if $dbi.nil?
    Chef::Log.info("------------ Fetching value for key \"#{key}\"")
    result = (node['chef-bcs']['enabled']['encrypt_data_bag']) ? $edbi[key] : $dbi[key]
    raise "No config found for get_item(#{key})!!!" if result.nil?
    return result
end

# Assumes hostname looks something like xxxxxxx-rNxxx
def get_rack_num(host)
  # Default to rack 1
  rack = 1
  if host
    index = host.index('-r')
    if !index.nil? && index > 0
      rack = host[index+2..-3]
    else
      rack = host[-1]
    end
  end
  rack.to_i
end

# Cycle through osd_devices to find a unique journals used.
def get_journals
  journals = []
  node['ceph']['osd']['devices'].each do | journal |
    if !journals.include? journal['journal']
      journals << journal['journal']
    end
  end
  journals
end

def is_bootstrap_node
  val = false
  if node['hostname'] == node['chef-bcs']['bootstrap']['name']
    val = true
  end
  val
end

def get_ip(interface)
  val = nil
  if is_bootstrap_node
    node['chef-bcs']['bootstrap']['interfaces'].each do | intf |
      if interface == intf
        val = intf['ip']
        break
      end
    end
  else
    servers = node['chef-bcs']['cobbler']['servers']
    servers.each do | server |
      if server['name'] == node['hostname']
        if interface == server['network']['public']['interface']
          val = server['network']['public']['ip']
        else
          val = server['network']['cluster']['ip']
        end
        break
      end
    end
  end
  val
end

def get_gateway(interface)
  val = nil
  if is_bootstrap_node
    node['chef-bcs']['bootstrap']['interfaces'].each do | intf |
      if interface == intf
        val = intf['gateway']
        break
      end
    end
  else
    servers = node['chef-bcs']['cobbler']['servers']
    servers.each do | server |
      if server['name'] == node['hostname']
        if interface == server['network']['public']['interface']
          val = server['network']['public']['gateway']
        else
          val = server['network']['cluster']['gateway']
        end
        break
      end
    end
  end
  val
end

def get_mac_address(interface)
  val = nil
  if is_bootstrap_node
    node['chef-bcs']['bootstrap']['interfaces'].each do | intf |
      if interface == intf
        val = intf['mac']
        break
      end
    end
  else
    servers = node['chef-bcs']['cobbler']['servers']
    servers.each do | server |
      if server['name'] == node['hostname']
        if interface == server['network']['public']['interface']
          val = server['network']['public']['mac']
        else
          val = server['network']['cluster']['mac']
        end
        break
      end
    end
  end
  val
end

def get_netmask(interface)
  val = nil
  if is_bootstrap_node
    node['chef-bcs']['bootstrap']['interfaces'].each do | intf |
      if interface == intf
        val = intf['netmask']
        break
      end
    end
  else
    servers = node['chef-bcs']['cobbler']['servers']
    servers.each do | server |
      if server['name'] == node['hostname']
        if interface == server['network']['public']['interface']
          val = server['network']['public']['netmask']
        else
          val = server['network']['cluster']['netmask']
        end
        break
      end
    end
  end
  val
end

# Bonding...
# Bond IP will be the public ip
def get_bond_ip
  val = nil
  if is_bootstrap_node
    interface = node['chef-bcs']['bootstrap']['interfaces'].first
    val = interface['ip']
  else
    servers = node['chef-bcs']['cobbler']['servers']
    servers.each do | server |
      if server['name'] == node['hostname']
        val = server['network']['public']['ip']
        break
      end
    end
  end
  val
end

def get_bond_gateway
  val = nil
  if is_bootstrap_node
    interface = node['chef-bcs']['bootstrap']['interfaces'].first
    val = interface['gateway']
  else
    servers = node['chef-bcs']['cobbler']['servers']
    servers.each do | server |
      if server['name'] == node['hostname']
        # IMPORTANT - VirtualBox environment should be named vagrant.json or vbox.json
        # Don't put a GATEWAY value in for a VirtualBox environment
        if node.chef_environment == 'vagrant' || node.chef_environment == 'vbox'
          val = ''
        else
          val = server['network']['public']['gateway']
        end
        break
      end
    end
  end
  val
end

def get_bond_netmask
  val = nil
  if is_bootstrap_node
    interface = node['chef-bcs']['bootstrap']['interfaces'].first
    val = interface['netmask']
  else
    servers = node['chef-bcs']['cobbler']['servers']
    servers.each do | server |
      if server['name'] == node['hostname']
        val = server['network']['public']['netmask']
        break
      end
    end
  end
  val
end

# ADC - Application Delivery Controller (load balancer)
def is_adc_node
  val = false
  nodes = adc_nodes
  nodes.each do |n|
    if n['hostname'] == node['hostname']
      val = true
      break
    end
  end
  val
end

def adc_nodes
  results = search(:node, "tags:#{node['chef-bcs']['adc']['tag']}")
  results.map! { |x| x['hostname'] == node['hostname'] ? node : x }
  if !results.include?(node) && node.run_list.roles.include?(node['chef-bcs']['adc']['tag'])
    results.push(node)
  end
  results.sort! { |a, b| a['hostname'] <=> b['hostname'] }
end

def is_adc_node_role(role)
  val = false

  if is_adc_node
    node['chef-bcs']['adc']['bgp']['roles'].each do |n|
      if n['name'] == node['hostname'] && n['role'] == role
        val = true
        break
      end
    end
  end

  val
end

# BGP uses the keepalived servers which always use the "public" interface
def get_bgp_interface_ip
  val = nil
  server = get_keepalived_server
  if server
    # Always the 'public' interface
    sys_server = get_server
    if sys_server
      val = sys_server['network']['public']['ip']
    end
  end
  val
end

def get_server
  val = nil
  servers = node['chef-bcs']['cobbler']['servers']
  servers.each do | server |
    if server['name'] == node['hostname']
      val = server
      break
    end
  end
  val
end

def get_keepalived_server
  val = nil
  servers = node['chef-bcs']['keepalived']['servers']
  servers.each do | server |
    if server['name'] == node['hostname']
      val = server
      break
    end
  end
  val
end

def get_adc_backend_nodes
  results = []
  # RGW are backend nodes...
  rgw_nodes = radosgw_nodes
  servers = node['chef-bcs']['cobbler']['servers']
  rgw_nodes.each do | rgw |
    servers.each do | server |
      if server['name'] == rgw['hostname']
        svr = {}
        svr['name'] = server['name']
        svr['instance'] = nil
        svr['type'] = get_backend_str_attr(server['name'], 'type')
        svr['ip'] = server['network']['public']['ip']
        svr['port'] = get_backend_int_attr(server['name'], 'port')
        svr['weight'] = get_backend_int_attr(server['name'], 'weight')
        svr['options'] = get_backend_str_attr(server['name'], 'options')
        results.push(svr)
      end
    end
  end
  results
end

# NOTE: The 'instance' value is added to the json environment file. 
def get_adc_backend_federated_nodes
  results = []
  # Get the list of backend servers
  nodes = node['chef-bcs']['adc']['backend']['servers']
  servers = node['chef-bcs']['cobbler']['servers']
  nodes.each do | bes |
    servers.each do | server |
      if server['name'] == bes['name']
        svr = {}
        svr['name'] = server['name']
        svr['ip'] = server['network']['public']['ip']
        svr['type'] = bes['type']
        svr['instance'] = bes['instance']
        svr['port'] = bes['port']
        svr['weight'] = bes['weight']
        svr['options'] = bes['options']
        results.push(svr)
      end
    end
  end
  results
end

def get_backend_int_attr(name, attr)
  val = 0
  backend_nodes = node['chef-bcs']['adc']['backend']['servers']
  backend_nodes.each do | backend |
    if backend['name'] == name
      val = backend[attr]
      break
    end
  end
  val
end

def get_backend_str_attr(name, attr)
  val = ''
  backend_nodes = node['chef-bcs']['adc']['backend']['servers']
  backend_nodes.each do | backend |
    if backend['name'] == name
      val = backend[attr]
      break
    end
  end
  val
end

def is_radosgw_node
  val = false
  nodes = radosgw_nodes
  nodes.each do |n|
    if n['hostname'] == node['hostname']
      val = true
      break
    end
  end
  val
end

def radosgw_nodes
  results = search(:node, "tags:#{node['ceph']['radosgw']['tag']}")
  results.map! { |x| x['hostname'] == node['hostname'] ? node : x }
  if !results.include?(node) && node.run_list.roles.include?(node['ceph']['radosgw']['role'])
    results.push(node)
  end
  results.sort! { |a, b| a['hostname'] <=> b['hostname'] }
end

def is_mon_node
  val = false
  nodes = mon_nodes
  nodes.each do |n|
    if n['hostname'] == node['hostname']
      val = true
      break
    end
  end
  val
end

def mon_nodes
  results = search(:node, "tags:#{node['ceph']['mon']['tag']}")
  results.map! { |x| x['hostname'] == node['hostname'] ? node : x }
  if !results.include?(node) && node.run_list.roles.include?(node['ceph']['mon']['role'])
    results.push(node)
  end
  results.sort! { |a, b| a['hostname'] <=> b['hostname'] }
end

def is_osd_node
  val = false
  nodes = osd_nodes
  nodes.each do |n|
    if n['hostname'] == node['hostname']
      val = true
      break
    end
  end
  val
end

def osd_nodes
  results = search(:node, "tags:#{node['ceph']['osd']['tag']}")
  results.map! { |x| x['hostname'] == node['hostname'] ? node : x }
  if !results.include?(node) && node.run_list.roles.include?(node['ceph']['osd']['role'])
    results.push(node)
  end
  results.sort! { |a, b| a['hostname'] <=> b['hostname'] }
end

def search_nodes(key, value)
    if key == "recipe"
        results = search(:node, "recipes:ceph\\:\\:#{value} AND chef_environment:#{node.chef_environment}")
        results.map! { |x| x['hostname'] == node['hostname'] ? node : x }
        if not results.include?(node) and node.run_list.expand(node.chef_environment).recipes.include?("ceph-chef::#{value}")
            results.push(node)
        end
    elsif key == "role"
        results = search(:node, "#{key}:#{value} AND chef_environment:#{node.chef_environment}")
        results.map! { |x| x['hostname'] == node['hostname'] ? node : x }
        if not results.include?(node) and node.run_list.expand(node.chef_environment).roles.include?(value)
            results.push(node)
        end
    else
        raise("Invalid search key: #{key}")
    end

    return results.sort! { |a, b| a['hostname'] <=> b['hostname'] }
end

def get_all_nodes
    results = search(:node, "recipes:ceph AND chef_environment:#{node.chef_environment}")
    if results.any? { |x| x['hostname'] == node['hostname'] }
        results.map! { |x| x['hostname'] == node['hostname'] ? node : x }
    else
        results.push(node)
    end
    return results.sort! { |a, b| a['hostname'] <=> b['hostname'] }
end

def get_ceph_osd_nodes
    results = search(:node, "recipes:ceph\\:\\:ceph-osd AND chef_environment:#{node.chef_environment}")
    if results.any? { |x| x['hostname'] == node['hostname'] }
        results.map! { |x| x['hostname'] == node['hostname'] ? node : x }
    else
        results.push(node)
    end
    return results.sort! { |a, b| a['hostname'] <=> b['hostname'] }
end

def get_bootstrap_node
    results = search(:node, "role:ceph-bootstrap AND chef_environment:#{node.chef_environment}")
    raise 'There is not exactly one bootstrap node found.' if results.size != 1
    results.first
end

def get_mon_nodes
    results = search(:node, "role:ceph-mon AND chef_environment:#{node.chef_environment}")
    # When this runs (up front) there is no actual 'node' attribute so just get all of them
    return results.sort! { |a, b| a['hostname'] <=> b['hostname'] }
end

def secure_password(len=20)
    pw = String.new
    while pw.length < len
        pw << ::OpenSSL::Random.random_bytes(1).gsub(/\W/, '')
    end
    pw
end

def secure_password_alphanum_upper(len=20)
    # Chef's syntax checker doesn't like multiple exploders in same line. Sigh.
    alphanum_upper = [*'0'..'9']
    alphanum_upper += [*'A'..'Z']
    # We could probably optimize this to be in one pass if we could easily
    # handle the case where random_bytes doesn't return a rejected char.
    raw_pw = String.new
    while raw_pw.length < len
        raw_pw << ::OpenSSL::Random.random_bytes(1).gsub(/\W/, '')
    end
    pw = String.new
    while pw.length < len
        pw << alphanum_upper[raw_pw.bytes().to_a()[pw.length] % alphanum_upper.length]
    end
    pw
end

# get_ceph_sockets
def get_ceph_sockets
    h = Hash.new()
    socket_basepath = '/var/run/ceph/'
    sockets = Dir.glob(File.join(socket_basepath, 'ceph-{mon,osd}*.asok'))
    if sockets.any?
        sockets.each do |socket|
            daemon = socket[/(mon|osd).*[0-9]/]
            h[daemon] = socket
        end
    end
    return h
end

# get_osd_mountpoints
def get_osd_mountpoints
    mount_basepath = '/var/lib/ceph/osd'
    mountpoints = Dir.glob(File.join(mount_basepath, '*')).sort
    mountpoints
end
