#
# Cookbook Name:: chef-bcs
# Library:: utils
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

def make_config(key, value)
    init_config if $dbi.nil?
    if $dbi[key].nil?
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

def config_defined(key)
    init_config if $dbi.nil?
    Chef::Log.info("------------ Checking if key \"#{key}\" is defined")
    result = (node['chef-bcs']['enabled']['encrypt_data_bag']) ? $edbi[key] : $dbi[key]
    return !result.nil?
end

def get_config(key)
    init_config if $dbi.nil?
    Chef::Log.info("------------ Fetching value for key \"#{key}\"")
    result = (node['chef-bcs']['enabled']['encrypt_data_bag']) ? $edbi[key] : $dbi[key]
    raise "No config found for get_config(#{key})!!!" if result.nil?
    return result
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

def ceph_keygen()
    key = "\x01\x00"
    key += ::OpenSSL::Random.random_bytes(8)
    key += "\x10\x00"
    key += ::OpenSSL::Random.random_bytes(16)
    Base64.encode64(key).strip
end

# We do not have net/ping, so just call out to system and check err value.
def ping_node(list_name, ping_node)
    Open3.popen3("ping -c1 #{ping_node}") { |stdin, stdout, stderr, wait_thr|
        rv = wait_thr.value
        if rv == 0
            Chef::Log.info("Success pinging #{ping_node}")
            return
        end
        Chef::Log.warn("Failure pinging #{ping_node} - #{rv} - #{stdout.read} - #{stderr.read}")
    }
    raise ("Network test failed: #{list_name} unreachable")
end

def ping_node_list(list_name, ping_list, fast_exit=true)
    success = false
    ping_list.each do |ping_node|
        Open3.popen3("ping -c1 #{ping_node}") { |stdin, stdout, stderr, wait_thr|
            rv = wait_thr.value
            if rv == 0
                Chef::Log.info("Success pinging #{ping_node}")
                return unless not fast_exit
                success = true
            else
                Chef::Log.warn("Failure pinging #{ping_node} - #{rv} - #{stdout.read} - #{stderr.read}")
            end
        }
    end
    if not success
        raise ("Network test failed: #{list_name} unreachable")
    end
end
