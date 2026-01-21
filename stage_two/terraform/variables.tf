# variables.tf - All configurable input variables for Stage 2

variable "vm_name" {
  description = "Friendly name of the Vagrant VM (shown in VirtualBox)"
  type        = string
  default     = "yolo-stage2"
}

variable "box" {
  description = "Vagrant box to use (should match Stage 1 for consistency)"
  type        = string
  default     = "geerlingguy/ubuntu2004"
}

variable "memory" {
  description = "RAM allocated to the VM in MB (enough for Docker + app)"
  type        = number
  default     = 2048
}

variable "cpus" {
  description = "Number of CPU cores for the VM"
  type        = number
  default     = 2
}

variable "ip_address" {
  description = "Private IP for the VM on VirtualBox host-only network (different from Stage 1)"
  type        = string
  default     = "192.168.56.20"

  validation {
    condition     = can(regex("^192\\.168\\.56\\.[0-9]{1,3}$", var.ip_address))
    error_message = "IP must be in the 192.168.56.0/24 range (VirtualBox host-only default)."
  }
}

variable "app_port" {
  description = "Port exposed for the Yolo frontend application"
  type        = number
  default     = 3000
}

variable "vagrant_provider" {
  description = "Vagrant provider to use (virtualbox is standard for local)"
  type        = string
  default     = "virtualbox"
}

variable "force_reprovision" {
  description = "Change this value (e.g. timestamp or random string) to force full destroy + reprovision"
  type        = string
  default     = "" # Empty = no force; override with -var 'force_reprovision=force-2026-01-21'
}