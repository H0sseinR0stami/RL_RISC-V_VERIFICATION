# syntax=docker/dockerfile:1

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_DEFAULT_TIMEOUT=1000
ENV PIP_RETRIES=10

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    make \
    gcc \
    g++ \
    cmake \
    verilator \
    python3 \
    python3-pip \
    python3-dev \
    device-tree-compiler \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY requirements.txt .

RUN --mount=type=cache,target=/root/.cache/pip \
    python3 -m pip install \
    --default-timeout=1000 \
    --retries=10 \
    -r requirements.txt

RUN curl -L \
        --retry 10 \
        --retry-delay 10 \
        --retry-all-errors \
        --connect-timeout 60 \
        -o /tmp/ibex.tar.gz \
        https://github.com/lowRISC/ibex/archive/refs/heads/master.tar.gz \
    && mkdir -p /workspace/ibex \
    && tar -xzf /tmp/ibex.tar.gz \
        --strip-components=1 \
        -C /workspace/ibex \
    && rm /tmp/ibex.tar.gz

CMD ["/bin/bash"]
