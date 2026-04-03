FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y wget gpg sudo curl ca-certificates openssl git tar sqlite3 fontconfig libfreetype6 tzdata iproute2 libstdc++6 \
    && mkdir -p /etc/apt/keyrings \
    && wget -qO - https://repo.radeon.com/rocm/rocm.gpg.key | gpg --dearmor | tee /etc/apt/keyrings/rocm.gpg > /dev/null \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/7.2.1 noble main" | tee /etc/apt/sources.list.d/rocm.list \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/graphics/7.2.1/ubuntu noble main" | tee -a /etc/apt/sources.list.d/rocm.list \
    && cat <<EOF > /etc/apt/preferences.d/rocm-pin-600
Package: *
Pin: release o=repo.radeon.com
Pin-Priority: 600
EOF

RUN apt-get update && apt-get install -y rocm-opencl-runtime \
    && wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/keyrings/adoptium.gpg > /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb noble main" | tee /etc/apt/sources.list.d/adoptium.list \
    && apt-get update \
    && apt-get install -y temurin-25-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/temurin-25-jdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb \
    && dpkg -i cuda-keyring_1.1-1_all.deb \
    && rm cuda-keyring_1.1-1_all.deb \
    && apt-get update \
    && apt-get install -y cuda-toolkit \
    && rm -rf /var/lib/apt/lists/*
    
RUN groupadd -g 988 pterodactyl || true \
    && useradd -u 988 -g 988 -d /home/container -m container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
