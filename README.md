# Configuration Management IP - Stage 2  
**Yolo E-commerce Platform with Terraform + Ansible**

This project is **Stage 2** of the Configuration Management IP.  
It uses **Terraform** to orchestrate the provisioning and then automatically triggers **Vagrant + Ansible** to deploy the same containerized Yolo e-commerce application.

**Live application URL after deployment:**  
→ http://192.168.56.20:3000

## Project Overview

- **Stage 1** → Ansible + Vagrant only (single VM)  
  → Located on the `stage_one` branch
- **Stage 2** (this branch) → **Terraform** + Vagrant + Ansible  
  → Creates a **second independent VM** (192.168.56.20)  
  → Uses `null_resource` + `local-exec` to automatically run `vagrant up` and Ansible

## Quick Start – Stage 2

```bash
# 1. Make sure you are on stage_two branch
git checkout stage_two

# 2. Go into terraform folder
cd stage_two/terraform

# 3. Initialize terraform (only needed first time)
terraform init

# 4. Deploy everything with one command
terraform apply -auto-approve

## Clean up
# Destroy everything
terraform destroy -auto-approve

# Also destroy the vagrant machine just to be super clean
cd .. && vagrant destroy -f

