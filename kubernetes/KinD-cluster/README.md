# KinD Cluster — Local Multi-Node Kubernetes in Docker

KinD (Kubernetes in Docker) runs a fully functional Kubernetes cluster inside Docker containers. This directory provides three setup paths — pick the one that matches your situation:

| Option | Best For | Setup Time |
|--------|----------|-----------|
| **A — Docker Compose** | Local laptop, beginners, zero manual installs | ~5 min |
| **B — VM / EC2 (manual)** | Learning each install step, Ubuntu VM practice | ~15 min |
| **C — Terraform on AWS** | Cloud lab, fully automated, repeatable | ~10 min (one command) |

---

## What the Cluster Looks Like

`kind-config.yml` defines a 3-node cluster:

```
control-plane  (kindest/node:v1.33.0)
worker-1       (kindest/node:v1.33.0)
worker-2       (kindest/node:v1.33.0)
```

The Docker Compose path also exposes the KinD API server on host port `6443`.

---

## Option A — Docker Compose (Recommended for Beginners)

The `Dockerfile` builds an Ubuntu image with all tools pre-installed:

| Tool | Version |
|------|---------|
| KinD | v0.30.0 |
| kubectl | v1.29.3 |
| Helm | v3.17.1 |
| Terraform | v1.11.2 |
| Go | v1.23.3 |

When the container starts, `entrypoint.sh` automatically:
1. Starts a Docker daemon inside the container (Docker-in-Docker)
2. Creates the KinD cluster
3. Installs the Calico CNI plugin
4. Initialises Helm repos and Terraform

### Step 1 — Create a local workspace folder

The container mounts a local folder into `/dsk01`. Create it first:

```bash
mkdir -p kubernetes/KinD-cluster/workspace
```

By default `docker-compose.yml` mounts `./workspace:/dsk01`. Change the left side of that volume line if you want to use a different path on your machine.

### Step 2 — (Optional) Add a custom KinD config

If you want to customise the cluster (add NodePort mappings, extra nodes, etc.), copy `kind-config.yml` into your workspace folder and rename it:

```bash
cp kubernetes/KinD-cluster/kind-config.yml kubernetes/KinD-cluster/workspace/kind-config.yaml
```

The entrypoint reads the file from `KIND_CONFIG_FILE=/dsk01/kind-config.yaml`. If that file is absent, a single-node default cluster is created instead.

### Step 3 — Build and start

```bash
cd kubernetes/KinD-cluster
docker compose up --build
```

Wait for the line `Docker is ready.` then `KinD cluster 'mycluster' already exists.` (or the creation log). The cluster is ready when you see the helm/terraform init output complete.

### Step 4 — Open a shell in the container

In a second terminal:

```bash
docker exec -it k8s-kind-cluster bash
```

### Step 5 — Verify the cluster

```bash
kubectl cluster-info --context kind-mycluster
kubectl get nodes
kubectl get pods -A
```

Expected nodes:

```
NAME                    STATUS   ROLES           AGE   VERSION
mycluster-control-plane Ready    control-plane   2m    v1.33.0
mycluster-worker        Ready    <none>          2m    v1.33.0
mycluster-worker2       Ready    <none>          2m    v1.33.0
```

### Environment variables (docker-compose.yml)

| Variable | Default | Purpose |
|----------|---------|---------|
| `KIND_CLUSTER_NAME` | `mycluster` | Name of the KinD cluster |
| `KIND_CONFIG_FILE` | `/dsk01/kind-config.yaml` | Path to custom cluster config inside the container |
| `KIND_WAIT` | `120s` | Timeout waiting for cluster to become ready |
| `CNI_PLUGIN` | `calico` | CNI to install (`calico`, `flannel`, or leave blank) |
| `INSECURE_REGISTRY` | `false` | Set `true` only if you have TLS issues with a private registry |

### Clean up

```bash
docker compose down --remove-orphans
```

---

## Option B — VM / EC2 Instance (Manual Install)

Use this path to practice each installation step on an Ubuntu 22.04 VM or EC2 instance.

### Step 1 — Provision and connect to an Ubuntu VM

SSH into the instance once it is running.

### Step 2 — Install tools

Make the scripts executable and run them in order:

```bash
chmod +x install_docker.sh install_kind.sh install_kubectl.sh install_helm.sh

./install_docker.sh    # Docker CE (from official Docker apt repo)
./install_kind.sh      # KinD v0.20.0
./install_kubectl.sh   # kubectl v1.30.0
./install_helm.sh      # Helm 3
```

> After `install_docker.sh`, log out and back in (or run `newgrp docker`) so your user can run Docker without `sudo`.

**Installed versions (manual path):**

| Tool | Version |
|------|---------|
| KinD | v0.20.0 |
| kubectl | v1.30.0 |
| Helm | 3 (latest at install time) |

### Step 3 — Create the cluster

```bash
kind create cluster --config=kind-config.yml
```

Expected output:

```
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.33.0)
 ✓ Preparing nodes
 ✓ Writing configuration
 ✓ Starting control-plane
 ✓ Installing CNI
 ✓ Installing StorageClass
 ✓ Joining worker nodes
Set kubectl context to "kind-kind"
```

### Step 4 — Verify the cluster

```bash
kubectl cluster-info --context kind-kind
kubectl get nodes
kind get clusters
```

```
NAME                 STATUS   ROLES           AGE   VERSION
kind-control-plane   Ready    control-plane   2m    v1.33.0
kind-worker          Ready    <none>          2m    v1.33.0
kind-worker2         Ready    <none>          2m    v1.33.0
```

### Step 5 — Check running Docker containers

Each KinD node runs as a Docker container:

```bash
docker ps
```

```
CONTAINER ID   IMAGE                  PORTS                      NAMES
314c70d760ba   kindest/node:v1.33.0   127.0.0.1:36321->6443/tcp  kind-control-plane
a0c3cfb63b7c   kindest/node:v1.33.0                              kind-worker
19d70a7867d2   kindest/node:v1.33.0                              kind-worker2
```

### Step 6 — Delete the cluster when done

```bash
kind delete cluster --name=kind
```

---

## Option C — Terraform on AWS (Quickest Cloud Setup)

Terraform provisions the EC2 instance, installs all tools, and boots the KinD cluster automatically — no manual SSH steps needed.

The stack lives in: **[samples-terraform/ec2-KinD-cluster](https://github.com/ritexlabs/devops-studio/tree/main/samples-terraform/ec2-KinD-cluster)**

### What Terraform Creates

- Ubuntu EC2 instance pre-sized for KinD
- Docker, KinD, kubectl, Helm installed via `user_data`
- KinD cluster started automatically on boot
- ALB listener rule → `https://<resource_prefix>-kind-dashboard.<domain_name>`

### Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform installed
- Existing in AWS: VPC, Security Group, ALB, EC2 Key Pair, Route 53 Hosted Zone

### Deploy

```bash
cd samples-terraform/ec2-KinD-cluster

# Edit terraform.tfvars with your values (VPC, SG, ALB, key pair, domain, …)
terraform init
terraform plan
terraform apply --auto-approve
```

### Verify

SSH into the instance using the IP from Terraform output:

```bash
ssh -i ~/.ssh/<your-key>.pem ubuntu@<ec2-public-ip>
kubectl get nodes
kubectl get pods -A
```

### Dashboard access

```
https://<resource_prefix>-kind-dashboard.<domain_name>
```

Login token is stored on the instance at `/home/ubuntu/configs/admin-user-token`.

### Tear down

```bash
terraform destroy --auto-approve
```

---

## Kubernetes Dashboard (Optional — All Options)

### Install

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
```

### Create the admin service account

`dashboard-adminuser.yml` creates a `ServiceAccount` and binds it to `cluster-admin`:

```bash
kubectl apply -f dashboard-adminuser.yml
```

### Generate a token

```bash
kubectl -n kubernetes-dashboard create token admin-user
```

Copy the token — you will paste it on the dashboard login page.

### Access via port-forward

```bash
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard 8443:443 --address=0.0.0.0 &
```

Open `https://localhost:8443` and paste the token. Expect a self-signed cert warning in your browser — click **Advanced → Proceed** to continue.

---

## Deploy a Sample Voting App (Optional Validation)

A quick end-to-end check that the cluster is working:

```bash
git clone https://github.com/dockersamples/example-voting-app.git
cd example-voting-app
kubectl apply -f k8s-specifications/
kubectl get all
```

Port-forward to access:

```bash
kubectl port-forward service/vote 5000:8080 --address=0.0.0.0 &
kubectl port-forward service/result 5001:8081 --address=0.0.0.0 &
```

- Vote: `http://localhost:5000`
- Results: `http://localhost:5001`

---

## File Reference

| File | Purpose |
|------|---------|
| `kind-config.yml` | KinD cluster topology — 1 control-plane + 2 workers, k8s v1.33.0 |
| `Dockerfile` | Multi-stage image: builder downloads binaries; runtime adds Docker + tools |
| `docker-compose.yml` | Runs the DinD container; mounts `./workspace` as `/dsk01` |
| `entrypoint.sh` | Container start script: starts dockerd, creates cluster, installs CNI, inits Helm/Terraform |
| `dashboard-adminuser.yml` | ServiceAccount + ClusterRoleBinding for dashboard admin login |
| `install_docker.sh` | Installs Docker CE from the official Docker apt repository (Option B) |
| `install_kind.sh` | Installs KinD v0.20.0 binary (Option B) |
| `install_kubectl.sh` | Installs kubectl v1.30.0 (Option B) |
| `install_helm.sh` | Installs Helm 3 using the official installer script (Option B) |
