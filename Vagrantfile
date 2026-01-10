Vagrant.configure("2") do |config|

  config.vm.box = "geerlingguy/ubuntu2004"

  config.vm.hostname = "yolo-dev"

  config.vm.network "private_network", ip: "192.168.56.10"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end

  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "playbook.yml"
    ansible.install = true
    ansible.install_mode = "pip"
    ansible.galaxy_role_file = "requirements.yml"
  end
end 