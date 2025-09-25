# Vagrantfile (control-node only)
Vagrant.configure("2") do |config|

  if Vagrant.has_plugin? "vagrant-vbguest"
    config.vbguest.no_install = true
    config.vbguest.auto_update = false
    config.vbguest.no_remote = true
  end

  config.vm.define "control-node" do |node|
    node.vm.box = "ubuntu/jammy64"         # Ubuntu 22.04
    node.vm.hostname = "control-node"
    node.vm.network "private_network", ip: "192.168.56.10"
    node.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end

    node.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update -y
      sudo apt-get install -y curl gnupg lsb-release software-properties-common unzip

      # Install HashiCorp repo + terraform
      curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
      sudo apt-get update -y
      sudo apt-get install -y terraform

      # Install Ansible
      sudo apt-add-repository --yes --update ppa:ansible/ansible
      sudo apt-get install -y ansible

      # Install Azure CLI (optional)
      curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

      # Ensure ssh-agent running and create key pair if not exists (so terraform can use)
      if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
        sudo -u vagrant ssh-keygen -t rsa -b 4096 -f /home/vagrant/.ssh/id_rsa -N ""
      fi
    SHELL
  end
end
