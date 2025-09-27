Vagrant.configure("2") do |config|

  if Vagrant.has_plugin? "vagrant-vbguest"
    config.vbguest.no_install = true
    config.vbguest.auto_update = false
    config.vbguest.no_remote = true
  end

  # Máquina de control
  config.vm.define "control-node" do |control|
    control.vm.box = "bento/ubuntu-22.04"  # Ubuntu 22.04
    control.vm.hostname = "control-node"
    control.vm.network "private_network", ip: "192.168.56.10"
    control.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
    end
    
    # Provisionar con script para instalar Terraform y Ansible
    control.vm.provision "shell", inline: <<-SHELL
      # Actualizar sistema
      apt-get update
      
      # Instalar dependencias
      apt-get install -y software-properties-common gnupg2 curl wget
      
      # Instalar Terraform
      wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
      apt-get update && apt-get install -y terraform
      
      # Instalar Ansible
      apt-get install -y ansible
      
      # Configurar usuario vagrant
      echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    SHELL
  end

  # Máquina target
  config.vm.define "web-node" do |web|
    web.vm.box = "bento/ubuntu-22.04"  # Ubuntu 22.04
    web.vm.hostname = "web-node"
    web.vm.network "private_network", ip: "192.168.56.20"
    web.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
  end
end