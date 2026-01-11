# Explanation of Ansible Playbook

## Reasoning for Execution Order
The playbook runs roles sequentially due to dependencies:
1. **common**: Preps system (updates, installs git)—runs first for all setups.
2. **docker-install**: Installs Docker—needed before any Docker tasks.
3. **clone-repo**: Clones app code—needed for building images.
4. **yolo-network**: Creates bridge network—containers connect here.
5. **mongo-volume**: Creates persistent volume—prevents data loss.
6. **mongo**: Deploys DB—backend depends on it.
7. **backend**: Builds/runs API—connects to Mongo, frontend depends on it.
8. **frontend**: Builds/runs UI—last, as it needs backend.

This mirrors your docker-compose depends_on.

## Role Functions & Modules
- **common**: System update/prep. Modules: apt.
- **docker-install**: Docker setup. Modules: apt, apt_key, apt_repository, user, service.
- **clone-repo**: Clone code. Modules: file, git.
- **yolo-network**: Network creation. Modules: community.docker.docker_network.
- **mongo-volume**: Volume for persistence. Modules: community.docker.docker_volume.
- **mongo**: Run Mongo container. Modules: community.docker.docker_container (in block for error handling).
- **backend**: Build/run backend. Modules: community.docker.docker_image, community.docker.docker_container.
- **frontend**: Build/run frontend. Modules: community.docker.docker_image, community.docker.docker_container.

Blocks used for rescues (error logging). Tags for selective runs (e.g., `ansible-playbook -t mongo playbook.yml`).
Variables from group_vars/all.yml for reusability.