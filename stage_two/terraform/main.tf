terraform {
  required_version = ">= 1.0"
}

variable "vm_name" {
  description = "Name of the Vagrant VM"
  type        = string
  default     = "yolo-stage2"
}

variable "box" {
  description = "Vagrant box to use"
  type        = string
  default     = "geerlingguy/ubuntu2004"
}

variable "memory" {
  type    = number
  default = 2048
}

variable "cpus" {
  type    = number
  default = 2
}

variable "ip_address" {
  description = "Private IP for the VM"
  type        = string
  default     = "192.168.56.20"
}

# This is a dummy resource — the real provisioning happens via local-exec
resource "null_resource" "vagrant_provision" {
  triggers = {
    always_run = timestamp()  
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "===== Provisioning Stage 2 with Vagrant & Ansible ====="
      cd ../..  # Go to repo root
      export VAGRANT_IP=${var.ip_address}
      vagrant destroy -f || true
      vagrant up --provider=virtualbox
      echo "Vagrant up complete. Running Ansible from inside VM..."
      vagrant ssh -c "cd /vagrant && ansible-playbook playbook.yml --extra-vars 'vm_ip=${var.ip_address}'"
      echo "Deployment finished! App should be at http://${var.ip_address}:3000"
    EOT
  }
}

output "vm_ip" {
  value       = var.ip_address
  description = "IP address of the Stage 2 VM"
}