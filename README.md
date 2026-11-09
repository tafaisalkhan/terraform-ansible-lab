# Terraform + Ansible Infrastructure Automation Lab

A hands-on DevOps learning project demonstrating how **Terraform and Ansible work together** to provision and configure Linux environments locally using Docker and Ubuntu WSL2.

The goal is to build practical experience with infrastructure as code, configuration management, SSH automation, idempotency, error handling, and eventually Java Spring Boot deployment.

## 1. Architecture

```text
Windows Laptop
│
├── Ubuntu WSL2
│   ├── Terraform (Infrastructure Provisioning)
│   └── Ansible (Configuration Management)
│
└── Docker Desktop
    ├── Nginx Container (Port 8085)
    ├── Ubuntu App Server 1 (SSH Port 2221)
    └── Ubuntu App Server 2 (SSH Port 2222)
```

**Terraform** creates and manages Docker infrastructure. **Ansible** connects to the Ubuntu containers over SSH and configures their software and application environments.

## 2. Technology Stack

| Technology | Purpose |
|---|---|
| Ubuntu WSL2 | Linux development environment |
| Docker Desktop | Local container runtime |
| Terraform | Infrastructure provisioning |
| Ansible | Configuration management |
| SSH | Secure connections to target servers |
| Python 3 | Ansible module execution |
| Java 21 | Spring Boot application runtime |
| Git / GitHub | Version control |

## 3. Project Structure

```text
terraform-ansible-lab/
├── terraform/
│   ├── main.tf
│   ├── servers.tf
│   └── .terraform.lock.hcl
├── ansible/
│   ├── ansible.cfg
│   ├── inventory.ini
│   ├── first-playbook.yml
│   └── install-java.yml
├── docker/
│   └── Dockerfile
├── .ssh/                 # Local SSH keys (not committed)
├── .venv/                # Python virtual environment
├── .gitignore
└── README.md
```

## 4. Prerequisites

- Windows with WSL2 and Ubuntu 24.04 or another compatible Ubuntu distribution
- Docker Desktop with WSL integration enabled
- Terraform installed in Ubuntu WSL2
- Ansible installed in a Python virtual environment
- Git and OpenSSH client

Verify:

```bash
docker version
terraform version
ansible --version
```

## 5. Provision Infrastructure Using Terraform

Generate an SSH key for the local lab:

```bash
mkdir -p .ssh
ssh-keygen -t ed25519 -f .ssh/ansible_lab -N ""
```

Build the custom Ubuntu image containing SSH and Python:

```bash
docker build -t ansible-lab-ubuntu:1.0 ./docker
```

Provision the containers:

```bash
cd terraform

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Verify:

```bash
docker ps
terraform state list
```

The infrastructure includes an Nginx web server and two SSH-enabled Ubuntu application containers.

Nginx is accessible at `http://localhost:8085`.

## 6. SSH Connectivity

Connect to the first Ubuntu container:

```bash
ssh -i .ssh/ansible_lab -p 2221 ansible@127.0.0.1
```

Connect to the second Ubuntu container:

```bash
ssh -i .ssh/ansible_lab -p 2222 ansible@127.0.0.1
```

The containers use public-key authentication. The private SSH key must never be committed to Git.

## 7. Ansible Inventory

The inventory defines the managed hosts:

```ini
[app_servers]
app1 ansible_host=127.0.0.1 ansible_port=2221
app2 ansible_host=127.0.0.1 ansible_port=2222

[app_servers:vars]
ansible_user=ansible
ansible_python_interpreter=/usr/bin/python3
```

Configure the SSH private key through the local Ansible configuration. The project-specific key is located at `.ssh/ansible_lab`.

## 8. Run Ansible

Activate the Python virtual environment and enter the Ansible directory:

```bash
cd ~/terraform-ansible-lab
source .venv/bin/activate
cd ansible
```

Test connectivity:

```bash
ansible app_servers -m ansible.builtin.ping
```

Expected response from both hosts:

```text
app1 | SUCCESS => {"ping": "pong"}
app2 | SUCCESS => {"ping": "pong"}
```

Run the first configuration playbook:

```bash
ansible-playbook first-playbook.yml
```

This playbook demonstrates:

- Collecting system facts
- Creating directories
- Managing application configuration
- Using variables and Jinja2 expressions
- Capturing task output with `register`
- Displaying diagnostic information

## 9. Install Java 21

Run:

```bash
ansible-playbook install-java.yml
```

The Java installation playbook demonstrates:

- Privilege escalation with `become`
- Package installation using `ansible.builtin.apt`
- Retries using `until`, `retries`, and `delay`
- Capturing command output with `register`
- Verifying the installed Java version
- Assertions for configuration validation

Verify independently:

```bash
ansible app_servers -m ansible.builtin.command -a "java -version"
```

## 10. Idempotency

Both Terraform and Ansible support declarative automation.

Terraform:

```bash
cd ../terraform
terraform plan
```

When infrastructure matches the configuration, Terraform should report no changes.

Ansible:

```bash
cd ../ansible
ansible-playbook first-playbook.yml
```

Run the playbook twice without modifying configuration. The second execution should report:

```text
changed=0
failed=0
```

This confirms that the playbook does not unnecessarily modify an already correctly configured environment.

## 11. Core Concepts

| Terraform | Ansible |
|---|---|
| Providers | Inventory |
| Resources | Playbooks |
| Variables | Variables |
| State management | Facts and registered results |
| Plan and apply | Tasks and modules |
| Resource dependencies | Handlers and task ordering |
| Infrastructure lifecycle | Configuration lifecycle |

## 12. Planned Enhancements

- [x] Install Terraform and Ansible in WSL2
- [x] Provision Nginx using Terraform
- [x] Create two Ubuntu Docker containers
- [x] Configure SSH authentication
- [x] Connect to both containers using Ansible
- [x] Create the first configuration playbook
- [x] Test Ansible idempotency
- [ ] Complete Java 21 installation and validation
- [ ] Simulate package installation failures
- [ ] Implement `block`, `rescue`, and `always`
- [ ] Implement handlers and notifications
- [ ] Organize playbooks using Ansible roles
- [ ] Manage secrets using Ansible Vault
- [ ] Deploy a Java Spring Boot application
- [ ] Add application health checks
- [ ] Integrate Jenkins CI/CD
- [ ] Extend the infrastructure to AWS

## 13. Cleanup

To remove infrastructure managed by Terraform:

```bash
cd terraform
terraform destroy
```

This removes the Terraform-managed containers and other managed resources. It does not delete the project source files.

## 14. Security Notes

This project is intended for local development and learning.

- Never commit SSH private keys or secrets.
- Exclude Terraform state files from Git.
- Restrict SSH ports to localhost.
- Use temporary, isolated containers for experimentation.
- Avoid passwordless administrative access in production without appropriate security controls.
- Use remote state storage, secret management, and least-privilege access when extending to cloud environments.

---

**Project status:** Local Terraform provisioning and Ansible connectivity/configuration are implemented. Java 21 deployment, resilience testing, and Spring Boot integration are the next stages.
