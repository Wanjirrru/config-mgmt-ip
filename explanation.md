# Explanation of Playbook & Infrastructure

## Stage 1 – Ansible Execution Order & Roles

Playbook runs sequentially due to dependencies:

1. common → system prep (apt update, utils)
2. docker-install → Docker + compose plugin
3. clone-repo → git clone app code
4. yolo-network → create bridge network
5. mongo-volume → persistent volume for data
6. mongo → DB container
7. backend → API container (depends on DB)
8. frontend → UI container (depends on API)

Modules used: apt, file, git, community.docker.docker_network/volume/container/image, service, user.

Variables from group_vars/all.yml (repo URL, image names, ports, etc.) for reusability.  
Blocks for error handling (rescue logs). Tags for selective runs.

Persistence: mongo-data volume ensures added products survive restarts.

## Stage 2 – Terraform + Ansible Integration

Terraform (in stage_two/terraform/) uses null_resource with local-exec provisioners to:
- Run `vagrant up` → provisions second VM at 192.168.56.20
- Execute Ansible playbook inside that VM

This achieves one-command infrastructure + configuration (terraform apply).

Reasoning: Terraform handles provisioning; Ansible handles configuration/deployment — loose coupling as per DevOps best practices.

Variables used in Terraform (e.g. for VM IP, app paths) and Ansible (same as Stage 1).

.tfstate committed for verification (no creds leaked); .tfstate.backup ignored in .gitignore.

Good practices: No hard-coded values, sequential dependency mirroring docker-compose.