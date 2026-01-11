# Stage 1 Yolo E-commerce Application
Ansible and Terraform for DevOps Automation
This repo automates deployment of the Yolo e-commerce app (from https://github.com/Wanjirrru/yolo) using Ansible on a Vagrant VM.

## Setup
1. Install Vagrant, VirtualBox, Ansible, and `ansible-galaxy collection install community.docker`.
2. `vagrant up` — provisions VM, runs Ansible, launches app.
3. Access frontend: http://192.168.56.10:3000
4. Test: Add a product via the form. Restart containers (`vagrant ssh` then `docker restart yolo-mongo yolo-backend yolo-frontend`)—product should persist due to volume.

## Testing Persistence 
- Add product
- `docker stop` containers
- `docker start` product remains

# Stage 2: Terraform + Ansible Integration

Terraform uses `null_resource` + `local-exec` to:
- Run `vagrant up` (provisions new VM at 192.168.56.20)
- SSH into VM
- Run Ansible playbook to deploy the same containerized app as Stage 1

Run:
cd stage_two/terraform
terraform init
terraform apply -auto-approve

Access app: http://192.168.56.20:3000

Clean up:
terraform destroy -auto-approve
vagrant destroy -f   # from root