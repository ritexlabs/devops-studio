#!/bin/bash
set -e

# Copy host CA certs if mounted
# if [ -d "/host-certs" ]; then
#     echo "Copying host CA certificates..."
#     cp -r /host-certs/* /etc/ssl/certs/
# fi

# Update CA certificates
echo "Updating CA certificates..."
update-ca-certificates
# echo "Using host CA certificates (read-only mount)..."

# Start Docker daemon for DinD
echo "Starting Docker daemon..."
dockerd --host=unix:///var/run/docker.sock --storage-driver=overlay2 &
until docker info >/dev/null 2>&1; do sleep 1; done
echo "Docker is ready."

# Create KinD cluster if not exists
if ! kind get clusters | grep -q "${KIND_CLUSTER_NAME}"; then
    echo "Creating KinD cluster: ${KIND_CLUSTER_NAME}"
    if [ -f "${KIND_CONFIG_FILE}" ]; then
        echo "Using custom KinD config: ${KIND_CONFIG_FILE}"
        kind create cluster --name "${KIND_CLUSTER_NAME}" --config "${KIND_CONFIG_FILE}" --wait "${KIND_WAIT}"
    else
        echo "Using default KinD config"
        kind create cluster --name "${KIND_CLUSTER_NAME}" --wait "${KIND_WAIT}"
    fi
else
    echo "KinD cluster '${KIND_CLUSTER_NAME}' already exists."
fi

# Install CNI plugin
if [ "${CNI_PLUGIN}" = "calico" ]; then
    echo "Installing Calico CNI plugin..."
    kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
elif [ "${CNI_PLUGIN}" = "flannel" ]; then
    echo "Installing Flannel CNI plugin..."
    kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
else
    echo "No CNI plugin installation requested or unsupported plugin: ${CNI_PLUGIN}"
fi

# Initialize Helm
echo "Initializing Helm..."
helm repo add stable https://charts.helm.sh/stable || true
helm repo update

# Initialize Terraform plugins
echo "Initializing Terraform..."
mkdir -p /dsk01/terraform && cd /dsk01/terraform
terraform init || true

exec "$@"