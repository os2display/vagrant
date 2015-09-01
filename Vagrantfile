VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "bento/debian-7.8"

  # IP
  config.vm.network "private_network", ip: "192.168.50.18"

  # Shared folder
  config.vm.synced_folder ".", "/vagrant", type: "nfs"

  # Hostname(s)
  config.vm.hostname = "indholdskanalen.vm"
  config.hostsupdater.aliases = ["screen.indholdskanalen.vm", "admin.indholdskanalen.vm", "search.indholdskanalen.vm", "middleware.indholdskanalen.vm"]

  # What to install
  config.vm.provision :shell, :path => "bootstrap.sh"
end
