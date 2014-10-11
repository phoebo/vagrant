# -*- mode: ruby -*-
# vi: set ft=ruby :

# Define puppet provisioning as a function
def puppet(config, provider)
  config.vm.provision :puppet do |pp|

    pp.module_path = "Puppet/modules"
    pp.manifests_path = "Puppet/manifests"
    pp.manifest_file  = "init.pp"

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

  # Host FQDN (.local suffix required)
  config.vm.hostname = "vagrant.local"

  # Host IP address
  config.vm.network :private_network, ip: "10.99.99.20"

  # Upgrade to newest Puppet on fresh install
  config.vm.provision :shell, :path => "Scripts/update-puppet.sh"

  # ----------------------------------------------------------------------------

  # Configuration for VirtualBox (Windows)
  config.vm.provider :virtualbox do |_, override|

    # Base setup: Ubuntu Server 14.04 LTS (Trusty Tahr) 64-bit
    config.vm.box = "ubuntu/trusty64"

    # VM will have 1.5 GB RAM as default
    _.memory = 512

    # Puppet with passed provider to facter
    puppet(override, "virtualbox")

  end

  # ----------------------------------------------------------------------------

  # Configuration for Parallels VM (Mac OS X)
  config.vm.provider :parallels do |_, override|

    # Base setup:  Ubuntu Server 14.04 LTS (Trusty Tahr) 64-bit for Parallels
    override.vm.box = "parallels/ubuntu-14.04"

    # VM will have 1.5 GB RAM as default
    _.memory = 512

    # Puppet with passed provider to facter
    puppet(override, "parallels")

  end

end
