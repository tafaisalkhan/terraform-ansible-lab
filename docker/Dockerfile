FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        python3 \
        sudo \
        ca-certificates && \
    mkdir -p /run/sshd && \
    useradd -m -s /bin/bash ansible && \
    mkdir -p /home/ansible/.ssh && \
    chown -R ansible:ansible /home/ansible/.ssh && \
    chmod 700 /home/ansible/.ssh && \
    echo 'ansible ALL=(ALL) NOPASSWD:ALL' \
        > /etc/sudoers.d/ansible && \
    chmod 440 /etc/sudoers.d/ansible && \
    rm -rf /var/lib/apt/lists/*

RUN printf 'PasswordAuthentication no\nPermitRootLogin no\n' \
    > /etc/ssh/sshd_config.d/99-lab.conf

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D", "-e"]
