FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y wget gpg sudo \
    && mkdir -p /etc/apt/keyrings \
    && wget -qO - https://repo.radeon.com/rocm/rocm.gpg.key | gpg --dearmor | tee /etc/apt/keyrings/rocm.gpg > /dev/null \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com jammy main" | tee /etc/apt/sources.list.d/rocm.list \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com jammy main" | tee --append /etc/apt/sources.list.d/rocm.list

RUN echo "Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600" | tee /etc/apt/preferences.d/rocm-pin-600 \
    && apt-get update && apt-get install -y rocm-opencl-runtime

RUN wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null \
    && echo "deb https://packages.adoptium.net/artifactory/deb jammy main" | tee /etc/apt/sources.list.d/adoptium.list \
    && apt-get update \
    && apt-get install -y temurin-25-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/temurin-25-jdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

RUN mkdir -p /dev/dri
