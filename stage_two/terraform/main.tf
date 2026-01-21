# main.tf - Stage 2: Terraform orchestrates Vagrant + remote Ansible (from host)
terraform {
  required_version = ">= 1.0.0"
}
resource "null_resource" "provision_yolo_stage2" {
  triggers = {
    force_reprovision = var.force_reprovision
  }

  provisioner "local-exec" {
    command = <<EOT
      set -e  # Exit on error

      echo "===== Starting Stage 2: Terraform → Vagrant → Ansible (remote from host) ====="

      cd ../..  # Go to repo root (adjust if your structure is different)

      echo "Destroying any existing VM (force)..."
      vagrant destroy -f || true

      echo "Bringing up Vagrant VM..."
      vagrant up --provider=${var.vagrant_provider}

      echo "Waiting for SSH to be ready on the VM..."
      # Quick wait + test SSH connectivity
      sleep 10
      vagrant ssh-config > ssh-config.tmp
      ssh -F ssh-config.tmp -o ConnectTimeout=5 -o StrictHostKeyChecking=no vagrant@localhost whoami || { echo "SSH not ready yet - waiting longer..."; sleep 20; }
      rm -f ssh-config.tmp

      echo "Running Ansible playbook remotely from host (using inventory/ansible.cfg)..."
      # Run from root dir where ansible.cfg + hosts exist
      ansible-playbook playbook.yml \
        --extra-vars "vm_ip=${var.ip_address} app_port=${var.app_port}" \
        --verbose || { echo "Ansible failed! Check logs."; exit 1; }

      echo "===== Deployment complete! ====="
      echo "Yolo e-commerce app should be at: http://${var.ip_address}:${var.app_port}"
      echo "Test persistence: Add product → vagrant halt && vagrant up → verify data remains"
    EOT
  }

  # Cleanup on terraform destroy
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      cd ../.. || exit 0
      vagrant destroy -f || true
      echo "Cleaned up Vagrant environment."
    EOT
  }
}
