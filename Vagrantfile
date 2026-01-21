Vagrant.configure("2") do |config|

  config.vm.box = "geerlingguy/ubuntu2004"

  config.vm.hostname = "yolo-dev"

# Choose IP based on environment variable (set when running Stage 2)
  ip_address = ENV['VAGRANT_IP'] || "192.168.56.10"  # Default = Stage 1
  config.vm.network "private_network", ip: ip_address

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end

config.vm.provision "ansible_local" do |ansible|
  ansible.playbook = "playbook.yml"
  ansible.install = true
  ansible.install_mode = "pip"
  ansible.pip_install_cmd = "sudo apt update && sudo apt install -y python3-pip && sudo pip3 install ansible"
  ansible.galaxy_role_file = "requirements.yml"
end
end
