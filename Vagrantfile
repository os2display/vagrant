VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "umtj/debian-7"
  config.vm.box_url = "http://gambit.etek.dk/vagrant/debian-7.box"

  # IP
  config.vm.network "private_network", ip: "192.168.50.18"

  # Shared folder
  config.vm.synced_folder ".", "/vagrant", type: "nfs"
 
  # Hostname(s)
  config.vm.hostname = "indholdskanalen.vm"
  config.hostsupdater.aliases = ["service.indholdskanalen.vm"]

  # What to install
  config.vm.provision :shell, :path => "bootstrap.sh"
end
