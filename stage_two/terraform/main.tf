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
  default     = "192.168.56.20"   # Different from Stage 1 to avoid conflict
}

# This resource triggers Vagrant up + Ansible deployment
resource "null_resource" "provision_yolo_stage2" {
  # Force re-run on every terraform apply (useful for testing)
  triggers = {
    vm_destroy = "${timestamp()}"  # Force full re-run
  }

provisioner "local-exec" {
  command = <<EOT
    echo "===== Starting Stage 2 Deployment ====="
    cd ../../ && VAGRANT_IP=192.168.56.20 vagrant destroy -f && VAGRANT_IP=192.168.56.20 vagrant up --provider=virtualbox
    echo "Vagrant VM is up with IP 192.168.56.20. Running Ansible..."
    vagrant ssh -c "cd /vagrant && ansible-playbook stage_two/ansible/playbook-stage2.yml"
    echo "Deployment complete! Access app at http://192.168.56.20:3000"
  EOT
}
}

# Output the IP for easy reference
output "vm_ip" {
  value       = var.ip_address
  description = "IP address of the Stage 2 VM"
}