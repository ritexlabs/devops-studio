# ---------- Stage 1: Builder ----------
FROM ubuntu:22.04 AS builder

ARG KUBECTL_VERSION=v1.29.3
ARG HELM_VERSION=v3.17.1
ARG TERRAFORM_VERSION=1.11.2
ARG KIND_VERSION=v0.30.0
ARG GO_VERSION=1.23.3

# Install build dependencies and CA certs
RUN apt-get update && \
    apt-get install -y ca-certificates git make build-essential unzip lsb-release && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Download and install Go using ADD
ADD https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz /tmp/go.tar.gz
RUN tar -C /usr/local -xzf /tmp/go.tar.gz && rm /tmp/go.tar.gz

# Set Go environment
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/root/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Download KinD binary using ADD
ADD https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64 /usr/local/bin/kind
RUN chmod +x /usr/local/bin/kind

# Download Helm using ADD
ADD https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz /tmp/helm.tar.gz
RUN tar -xvf /tmp/helm.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm -rf /tmp/helm.tar.gz linux-amd64

# Download Terraform using ADD
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip /tmp/terraform.zip
RUN unzip /tmp/terraform.zip && \
    mv terraform /usr/local/bin/terraform && \
    chmod +x /usr/local/bin/terraform && \
    rm /tmp/terraform.zip

# Download kubectl using ADD
ADD https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl

# ---------- Stage 2: Runtime ----------
FROM ubuntu:22.04

# Install Docker Engine and runtime essentials
RUN apt-get update && \
    apt-get install -y docker.io bash curl git ca-certificates && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Copy binaries from builder stage
COPY --from=builder /usr/local/go /usr/local/go
COPY --from=builder /usr/local/bin/kind /usr/local/bin/kind
COPY --from=builder /usr/local/bin/helm /usr/local/bin/helm
COPY --from=builder /usr/local/bin/terraform /usr/local/bin/terraform
COPY --from=builder /usr/local/bin/kubectl /usr/local/bin/kubectl

# Set Go environment
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/root/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Working directory
WORKDIR /dsk01

# Environment variables for KinD customization
ENV KIND_CLUSTER_NAME="kind"
ENV KIND_CONFIG_FILE="/dsk01/kind-config.yaml"
ENV KIND_WAIT="60s"
ENV CNI_PLUGIN="calico"

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]