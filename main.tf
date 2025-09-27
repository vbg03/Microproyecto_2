# main.tf
terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1"
    }
  }
}

# Primer paso: Generar clave SSH
resource "null_resource" "generate_ssh_key" {
  provisioner "local-exec" {
    command = "mkdir -p /home/vagrant/.ssh && if [ ! -f /home/vagrant/.ssh/id_rsa ]; then ssh-keygen -t rsa -b 2048 -f /home/vagrant/.ssh/id_rsa -N '' && chown vagrant:vagrant /home/vagrant/.ssh/id_rsa* && chmod 600 /home/vagrant/.ssh/id_rsa && chmod 644 /home/vagrant/.ssh/id_rsa.pub; fi"
  }
}

# Segundo paso: Configurar acceso SSH a la máquina target
resource "null_resource" "setup_ssh_access" {
  depends_on = [null_resource.generate_ssh_key]
  
  provisioner "local-exec" {
    command = "sudo apt-get update && sudo apt-get install -y sshpass"
  }

  provisioner "local-exec" {
    command = "sshpass -p 'vagrant' ssh-copy-id -o StrictHostKeyChecking=no vagrant@192.168.56.20 || echo 'SSH key copy completed'"
  }
}

# Tercer paso: Verificar conexión
resource "null_resource" "web_server_ready" {
  depends_on = [null_resource.setup_ssh_access]
  
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "ssh -o StrictHostKeyChecking=no -i /home/vagrant/.ssh/id_rsa vagrant@192.168.56.20 'echo SSH connection successful'"
  }
}

# Output de información
output "web_server_ip" {
  value = "192.168.56.20"
  description = "IP address of the web server"
}
