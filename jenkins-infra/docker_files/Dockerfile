FROM jenkins/inbound-agent:latest-jdk17

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      apt-transport-https \
      ca-certificates \
      wget \
      git \
      gnupg2 \
      software-properties-common && \
    wget -qO /tmp/hashicorp.gpg https://apt.releases.hashicorp.com/gpg && \
    gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg /tmp/hashicorp.gpg && \
    rm /tmp/hashicorp.gpg  && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && apt-get install -y terraform && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g 984 docker || true && usermod -aG docker jenkins

RUN wget -qO get-docker.sh https://get.docker.com && \
    sh get-docker.sh && \
    rm get-docker.sh

RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER jenkins
