# -*- mode: ruby -*-
# vi: set ft=ruby :

# Define puppet provisioning as a function
def puppet(config, provider)
  config.vm.provision :puppet do |pp|

    pp.module_path = "Puppet/modules"
    pp.manifests_path = "Puppet/manifests"
    pp.manifest_file  = "init.pp"
    pp.hiera_config_path = "Hiera.yaml"

    pp.options = [
      "--templatedir",
      "/vagrant/Puppet/templates",

      # Uncomment for Puppet debugging
      # "--verbose",
      # "--debug"
    ]

    pp.facter = {
      "provider" => provider,
      "vagrant" => 1
    }
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

  config.vm.define :www do |node|
    node.vm.hostname = "phoebo-www.local"

    # Base setup:  Ubuntu Server 14.04 LTS (Trusty Tahr) 64-bit for Parallels
    node.vm.box = "parallels/ubuntu-14.04"

    # Setup provider
    node.vm.provider "parallels" do |provider|
      # VM will have 1.5 GB RAM as default
      provider.memory = 1536
    end

    # Initial setup (before Puppet kicks in)
    node.vm.provision :shell, :path => "Scripts/01_update-system.sh"
    node.vm.provision :shell, :path => "Scripts/02_update-system-ruby.sh"
    node.vm.provision :shell, :path => "Scripts/03_update-puppet.sh", :args => [ "Puppetfile_www" ]

    # Auto-host
    node.vm.provision :hostmanager

    # Puppet setup
    node.vm.provision :puppet do |pp|
      pp.module_path = "Puppet/modules"
      pp.manifests_path = "Puppet/manifests"
      pp.manifest_file  = "init_www.pp"
      pp.hiera_config_path = "Hiera/www.yaml"

      pp.options = [
        "--templatedir",
        "/vagrant/Puppet/templates",
      ]
    end
  end

end
