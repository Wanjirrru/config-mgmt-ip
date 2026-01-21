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
  value = join("\n", [
    "Access the app at: http://${var.ip_address}:${var.app_port}",
    "",
    "Test persistence:",
    "1. Add a product via the form",
    "2. Run: vagrant halt && vagrant up",
    "3. Refresh browser → product should still be there"
  ])
}