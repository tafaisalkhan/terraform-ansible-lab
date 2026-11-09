resource "docker_container" "app_servers" {
  count = 2

  name  = "ansible-app-${count.index + 1}"
  image = "ansible-lab-ubuntu:1.0"

  ports {
    internal = 22
    external = 2221 + count.index
    ip       = "127.0.0.1"
  }

  upload {
    file = "/home/ansible/.ssh/authorized_keys"

    content = "${trimspace(file("${path.module}/../.ssh/ansible_lab.pub"))}\n"
  }
}
