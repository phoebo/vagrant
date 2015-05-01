# -*- mode: ruby -*-
# vi: set ft=ruby :

def setup_common(id, options = {})
  node = options[:for_node]
  options[:memory] ||= 1024

  # Base setup:  Ubuntu Server 14.04 LTS (Trusty Tahr) 64-bit for Parallels
  node.vm.box = "parallels/ubuntu-14.04"

  # Setup provider
  node.vm.provider "parallels" do |provider|
    provider.memory = options[:memory]
  end

  # Puppet setup
  node.vm.provision :puppet do |pp|
    pp.module_path = "Puppet/modules"
    pp.manifests_path = "Puppet/manifests"
    pp.manifest_file  = "init_#{id}.pp"
    pp.hiera_config_path = "Hiera/#{id}.yaml"
  end
end

# ------------------------------------------------------------------------------

Vagrant.configure("2") do |config|
  # Uncomment for off-line use
  config.vm.box_check_update = false

  # Hostmanager
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = true

  config.vm.define :master do |node|
    # Hostname
    node.vm.hostname = "phoebo.local"

    # Auto-host
    node.hostmanager.aliases = [
      # Singularity UI
      "singularity.#{node.vm.hostname}"
    ]
    node.vm.provision :hostmanager

    # Initial setup (before Puppet kicks in)
    node.vm.provision :shell, :path => "Scripts/01_update-system.sh"
    node.vm.provision :shell, :path => "Scripts/02_update-system-ruby.sh"
    node.vm.provision :shell, :path => "Scripts/03_update-puppet.sh", :args => [ "Puppetfile_master" ]

    # Common setup
    setup_common :master, for_node: node, memory: 1536
  end

  config.vm.define :slave1 do |node|
    # Hostname
    node.vm.hostname = "slave1.phoebo.local"

    # Auto-host
    node.vm.provision :hostmanager

    # Initial setup (before Puppet kicks in)
    node.vm.provision :shell, :path => "Scripts/01_update-system.sh"
    node.vm.provision :shell, :path => "Scripts/03_update-puppet.sh", :args => [ "Puppetfile_slave" ]

    # Common setup
    setup_common :slave, for_node: node
  end
end
