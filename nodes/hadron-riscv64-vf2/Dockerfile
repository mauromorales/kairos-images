# Hadron (riscv64) + Kairos + our riscv64 k0s, for the StarFive VisionFive 2.
# Hadron publishes no riscv64 image, so the base is built by hand (see README.md) and
# is called hadron-init:latest by Hadron's Makefile. Build this layer with:
#   docker build --platform linux/riscv64 -t <tag> nodes/hadron-riscv64-vf2
ARG BASE=hadron-init:latest
FROM ${BASE}
ARG KAIROS_VERSION=v4.4.0
ARG K0S_RISCV64_RELEASE=k0s-riscv64-v1.36.4-k0s.0
ARG K0S_RISCV64_FILE=k0s-v1.36.4%2Bk0s.0-linux-riscv64
ARG K0S_RISCV64_SHA256=d6aeb07b7a1cf0185ac9bfdbaeedea8bac7d74f8ca7abfd125d711deb02eb953
ADD https://github.com/kairos-io/kairos/releases/download/${KAIROS_VERSION}/provider-kairos-${KAIROS_VERSION}-linux-riscv64.tar.gz /tmp/provider.tar.gz
ADD https://github.com/mauromorales/kairos-images/releases/download/${K0S_RISCV64_RELEASE}/${K0S_RISCV64_FILE} /usr/bin/k0s
RUN mkdir -p /system/providers && tar -xzO -f /tmp/provider.tar.gz provider-kairos > /system/providers/agent-provider-kairos && \
    chmod +x /system/providers/agent-provider-kairos && ln -sf /system/providers/agent-provider-kairos /usr/bin/kairos && \
    echo "${K0S_RISCV64_SHA256}  /usr/bin/k0s" | sha256sum -c - && chmod +x /usr/bin/k0s && rm /tmp/provider.tar.gz
