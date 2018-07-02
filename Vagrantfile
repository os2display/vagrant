VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  # IP
  config.vm.network "private_network", ip: "192.168.50.129"

  # Shared folder
  config.vm.synced_folder ".", "/vagrant",
    :nfs => true,
    :mount_options => ['actimeo=2']

  # Timeout if box hangs
  config.vm.boot_timeout = 60

  # Hostname(s)
  config.vm.hostname = "os2display.vm"
  config.hostsupdater.aliases = [
    # Add additional hostnames here.
    "admin.os2display.vm",
    "screen.os2display.vm",
    "middleware.os2display.vm",
    "search.os2display.vm"
  ]

  config.vm.provision "shell", inline: <<-SHELL
    sed -i '$ a 127.0.1.1 screen.os2display.vm admin.os2display.vm search.os2display.vm middleware.os2display.vm' /etc/hosts
  SHELL

  config.bindfs.bind_folder '/vagrant', '/vagrant'

  # What to install
  config.vm.provision :ansible do |ansible|
    ansible.playbook = "playbook.yml"
    ansible.raw_arguments = Shellwords.shellsplit(ENV['ANSIBLE_ARGS']) if ENV['ANSIBLE_ARGS']
  end

  # Disable vbguest update, as it hanges.
  config.vbguest.no_remote = true
  config.vbguest.auto_update = false

  # SSH
  config.ssh.forward_agent = true
  config.ssh.insert_key = false
end
