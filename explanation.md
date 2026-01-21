# Explanation of Playbook & Infrastructure

## Stage 1 – Ansible Execution Order & Roles

The playbook (`playbook.yml`) runs tasks and roles sequentially because each step has explicit dependencies on the previous ones. The order is designed to mirror a typical application deployment workflow:

1. **common** → Prepares the base system (apt update/upgrade, install common utilities, create app user if needed)  
2. **docker-install** → Installs Docker Engine, Docker Compose plugin, and adds user to docker group  
3. **clone-repo** → Clones the GitHub repository containing the Yolo e-commerce application code  
4. **yolo-network** → Creates a custom Docker bridge network for inter-container communication  
5. **mongo-volume** → Creates a named Docker volume for persistent MongoDB data storage  
6. **mongo** → Pulls and starts the MongoDB container (depends on network + volume)  
7. **backend** → Pulls/builds and starts the Node.js/Express API container (depends on MongoDB being healthy)  
8. **frontend** → Pulls/builds and starts the React frontend container (depends on backend API)

**Ansible modules used**:
- `apt`, `apt_key`, `apt_repository` → package management
- `file`, `user`, `group` → filesystem and user setup
- `git` → cloning the repository
- `community.docker.docker_network`, `community.docker.docker_volume`, `community.docker.docker_container`, `community.docker.docker_image` → full Docker orchestration
- `service`, `systemd` → managing services if needed
- `debug`, `command`, `shell` → utility and verification tasks

**Good practices applied**:
- All configurable values (repo URL, image tags, ports, versions, volume names) are stored in `group_vars/all.yml` for reusability and single-point-of-change.
- `block` / `rescue` / `always` used in critical tasks for error handling and logging.
- Tags applied to major sections (e.g. `tags: install-docker`, `tags: deploy-app`) for selective execution during testing/debugging.

**Persistence**:
- The `mongo-volume` role creates a Docker named volume (`mongo-data`). This ensures product data added via the e-commerce form survives container restarts, VM reboots, or `vagrant destroy/up` cycles.

## Stage 2 – Terraform + Ansible Integration

In Stage 2, infrastructure provisioning and application configuration are orchestrated together using **Terraform as the primary entry point**, with Ansible handling the detailed server and container setup inside the newly provisioned VM.

**Execution flow**:
1. Run `terraform apply` in `stage_two/terraform/`
2. Terraform initializes and applies configuration
3. The `null_resource.provision_yolo_stage2` resource executes a `local-exec` provisioner:
   - Destroys any existing conflicting VM
   - Runs `vagrant up --provider=virtualbox` to provision a second Ubuntu VM at `192.168.56.20` (different IP from Stage 1 to avoid port/collision issues)
   - Uses `vagrant ssh` to execute `ansible-playbook` **inside the VM** against the local `/vagrant` mounted directory
4. Ansible (same `playbook.yml` as Stage 1, or a variant) applies the roles in the same sequential order described above
5. Application becomes available at `http://192.168.56.20:3000`

**Why this approach?**
- Terraform is excellent for declarative infrastructure provisioning (even local VMs via Vagrant).
- Ansible excels at configuration management and application deployment inside servers.
- Using `local-exec` in Terraform creates a clean one-command workflow (`terraform apply`) that provisions **and** configures the full environment — aligning with the assignment goal of automation and integration.
- Loose coupling: Terraform handles "create the machine", Ansible handles "install and run the app on it".
- Avoids more complex remote state or cloud providers, keeping it simple/local as per the course scope.

**Variables usage**:
- Terraform (`variables.tf`): `vm_name`, `box`, `memory`, `cpus`, `ip_address`, `app_port`, `force_reprovision`, etc. — all with descriptions, types, defaults, and validation where applicable.
- Ansible: Reuses `group_vars/all.yml` for app-specific values (repo URL, ports, image names, etc.)
- Passed dynamically where needed (e.g. `--extra-vars 'vm_ip=... app_port=...'` from Terraform to Ansible)

**State management**:
- `terraform.tfstate` is committed to GitHub for verification and reproducibility.
- `.tfstate.backup` and sensitive files are ignored via `.gitignore` (no credentials are present).

**Good practices**:
- No hard-coded values in code — everything configurable via variables.
- Sequential role execution mirrors dependencies (same as Stage 1).
- Clear outputs (`vm_ip`, `app_url`, instructions) shown after `terraform apply`.
- Designed for easy cleanup: `terraform destroy` + `vagrant destroy`.

This combined Terraform + Ansible approach provides a fully automated, repeatable way to stand up the containerized e-commerce platform on a fresh VM.