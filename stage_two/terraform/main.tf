# main.tf - Core configuration for Stage 2 provisioning
terraform {
  required_version = ">= 1.0.0"
}

# Dummy resource that triggers the full Vagrant + Ansible workflow
resource "null_resource" "provision_yolo_stage2" {
  # Triggers re-run when force_reprovision changes (set via -var or tfvars)
  triggers = {
    force_reprovision = var.force_reprovision
    # Optional: Add file hashes for better change detection (uncomment if desired)
    # vagrantfile_hash = filesha256("../../Vagrantfile")
    # playbook_hash    = filesha256("../../playbook.yml")
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "===== Starting Stage 2 Deployment (Terraform → Vagrant → Ansible) ====="
      cd ../..  # Move to repo root
      export VAGRANT_IP=${var.ip_address}
      vagrant destroy -f || true
      vagrant up --provider=${var.vagrant_provider}
      echo "Vagrant VM is up at ${var.ip_address}. Running Ansible configuration..."
      vagrant ssh -c "cd /vagrant && ansible-playbook playbook.yml --extra-vars 'vm_ip=${var.ip_address} app_port=${var.app_port}'"
      echo "===== Deployment complete! ====="
      echo "Access the Yolo e-commerce app at: http://${var.ip_address}:${var.app_port}"
      echo "Test persistence: Add a product → vagrant halt/up → verify it remains"
    EOT

    # Optional: Add error handling or environment setup
    environment = {
      VAGRANT_EXPERIMENTAL = "disks"  # If using newer Vagrant features
    }
  }

  # Optional: Clean up on destroy (good practice)
  provisioner "local-exec" {
    when    = destroy
    command = "vagrant destroy -f || true"
  }
}