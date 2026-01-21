# outputs.tf - Useful values displayed after terraform apply

output "vm_ip" {
  description = "Private IP address of the provisioned Stage 2 VM"
  value       = var.ip_address
}

output "app_url" {
  description = "Full URL to access the Yolo e-commerce application"
  value       = "http://${var.ip_address}:${var.app_port}"
}

output "access_instructions" {
  description = "Quick reminder on how to test the app"
  value       = <<EOT
Access the app at: ${output.app_url.value}
Test persistence:
1. Add a product via the form
2. Run: vagrant halt && vagrant up
3. Refresh browser → product should still be there
EOT
}