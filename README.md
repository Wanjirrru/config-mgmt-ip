# Configuration Management IP - Yolo E-commerce App
This project automates ddeployment of the Yolo e-commerce platform (from https://github.com/Wanjirrru/yolo) using Ansible + Docker on Vagrant (Stage 1) and Terraform + Ansible (Stage 2).

## Stages Overview
- **stage_one branch** Stage 1: Ansible playbook + Vagrant VM (IP: 192.168.56.10)
- **stage_two branch** Stage 2: Terraform provisions resources (via null_resource + local-exec), triggers VAgrant + Ansible on a second VM (IP: 192.168.56.20)

# Stage 1 Run with Vagrant + Ansible
1. Install prerequisites: Vagrant, VirtualBox, Ansible, and (`ansible-galaxy collection install community.docker`).
2. `vagrant up` — provisions VM, runs Ansible, launches app.
3. Access frontend: http://192.168.56.10:3000
4. Test persistence: Add a product via the form. Restart containers (`vagrant ssh` then `docker restart yolo-mongo yolo-backend yolo-frontend`) — refresh browser (product should persist due to volume).

## Testing Persistence 
- Add product
- `docker stop` containers
- `docker start` product remains

# Stage 2: Run with Terraform + Ansible
1. Checkout the branch `git checkout stage_two`
2. `cd stage_two/terraform`
3. `terraform init`
4. `terraform apply -auto-approve`
 -This provisions a new Vagrant VM (192.168.56.20), runs `vagrant up`, and executes Ansible to deploy the app.
5. Access: http://192.168.56.20:3000
6. Cleanup: `terraform destroy -auto-approve` && `vagrant destroy -f`

See `explanation.md` for detaile role order, modules and Terraform intergration reasoning.