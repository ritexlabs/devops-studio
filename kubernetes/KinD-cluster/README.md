# KinD Cluster — Local Multi-Node Kubernetes in Docker

KinD (Kubernetes in Docker) runs a fully functional Kubernetes cluster inside Docker containers on your local machine. This directory provides three setup paths — pick the one that matches your environment:

- **Option A — Docker Compose (recommended for beginners):** Spins up a pre-configured container that includes all tools and creates the cluster automatically.
- **Option B — VM / EC2 Instance (manual):** Installs tools directly on Ubuntu and creates the cluster manually. Ideal for practising on a cloud VM.
- **Option C — Terraform (quickest cloud setup):** Fully automated — provisions the EC2 instance, installs all tools, and configures the KinD cluster with a single `terraform apply`. No manual SSH steps required.

---

## What Is Created

| Resource | Detail |
|----------|--------|
| Kubernetes version | v1.33.0 |
| Cluster topology | 1 control-plane + 2 worker nodes |
| Exposed NodePorts | 32000 – 32010 (mapped to your host) |
| Tools included | `kubectl`, `kind`, `helm`, `terraform`, `go` |

---

## Option A — Docker Compose (Recommended)

### Prerequisites

- Docker Desktop or Docker Engine installed and running
- Docker Compose v2 (`docker compose version`)

### Step 1 — Configure your workspace volume

Open `docker-compose.yml` and update the host path in the `volumes` section to point to your own local workspace:

```yaml
volumes:
  - /your/local/workspace:/dsk01   # ← change the left side
```

### Step 2 — Build and start the container

```bash
docker compose up --build
```

The entrypoint script will:
1. Start a Docker daemon inside the container (Docker-in-Docker).
2. Create the KinD cluster using `kind-config.yml`.
3. Install the Calico CNI plugin.
4. Initialize Helm and Terraform.

### Step 3 — Attach to the container

```bash
docker compose run k8s-kind-cluster
# or, if already running:
docker exec -it k8s-kind-cluster bash
```

### Step 4 — Verify the cluster

```bash
kubectl cluster-info --context kind-mycluster
kubectl get nodes
kubectl get pods -A
```

Expected output:

```
NAME                 STATUS   ROLES           AGE   VERSION
kind-control-plane   Ready    control-plane   2m    v1.33.0
kind-worker          Ready    <none>          2m    v1.33.0
kind-worker2         Ready    <none>          2m    v1.33.0
```

### Clean up

```bash
docker compose down --remove-orphans
```

---

## Option B — VM / EC2 Instance (Ubuntu 22.04)

### Step 1 — Provision an Ubuntu VM or EC2 instance

Connect via SSH once the instance is running.

### Step 2 — Install required tools

Run the install scripts in order:

```bash
chmod +x install_docker.sh install_kind.sh install_kubectl.sh install_helm.sh

./install_docker.sh    # installs Docker CE
./install_kind.sh      # installs KinD v0.20.0
./install_kubectl.sh   # installs kubectl v1.30.0
./install_helm.sh      # installs Helm 3
```

> After installing Docker, log out and back in (or run `newgrp docker`) so your user can run Docker commands without `sudo`.

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

### Step 5 — Delete the cluster when done

```bash
kind delete cluster --name=kind
```

---

## Option C — Terraform on AWS (Quickest Cloud Setup)

If you have an AWS account with existing networking (VPC, Security Group, ALB, Route 53 hosted zone), Terraform can provision the entire EC2 + KinD environment with a single command — no manual installation or SSH steps required.

The Terraform stack is in: **[samples-terraform/ec2-KinD-cluster](https://github.com/ritexlabs/devops-studio/tree/main/samples-terraform/ec2-KinD-cluster)**

### What Terraform Creates

- An EC2 instance (Ubuntu) sized for KinD
- Docker, KinD, kubectl, and Helm installed automatically via `user_data`
- A KinD cluster started at boot with NodePorts `32000–32010` exposed
- An ALB listener rule routing `https://<resource_prefix>-kind-dashboard.<domain_name>` to the Kubernetes Dashboard

### Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform installed (`terraform -version`)
- Existing AWS resources: VPC, Security Group, ALB, EC2 Key Pair, Route 53 Hosted Zone

### Step 1 — Clone the stack

```bash
cd samples-terraform/ec2-KinD-cluster
```

### Step 2 — Configure `terraform.tfvars`

Edit `terraform.tfvars` and fill in your environment values:

```hcl
aws_region     = "us-east-2"          # AWS region for the EC2 instance
vpc_name       = "playground-vpc"     # Name of your existing VPC
sg_name        = "playground-sg"      # Existing security group name
alb_name       = "playground-alb"     # Existing ALB name (for dashboard routing)
hosted_zoneid  = "Z0XXXXXXXXXX"       # Route 53 hosted zone ID
resource_prefix = "kind"              # Prefix applied to all created resource names
ec2_source_ami = "ami-0f5fcdfbd140e4ab7"  # Ubuntu 22.04 AMI for us-east-2 (update for other regions)
key_pair_name  = "my-keypair"         # EC2 key pair for SSH access
domain_name    = "example.com"        # Your domain (dashboard URL: kind-kind-dashboard.example.com)
tag_envname    = "kind"               # Environment tag
```

> Find the correct Ubuntu 22.04 AMI for your region in the [AWS AMI Catalog](https://us-east-1.console.aws.amazon.com/ec2/home#AMICatalog).

### Step 3 — Deploy

```bash
terraform init
terraform plan
terraform apply --auto-approve
```

Terraform will output the EC2 instance public IP and the dashboard URL when complete.

### Step 4 — Verify the cluster

SSH into the instance (replace with your key and the IP from Terraform output):

```bash
ssh -i ~/.ssh/my-keypair.pem ubuntu@<ec2-public-ip>
```

Inside the instance:

```bash
kubectl cluster-info
kubectl get nodes
kubectl get pods -A
```

### Step 5 — Access the Kubernetes Dashboard

The dashboard is reachable at:

```text
https://<resource_prefix>-kind-dashboard.<domain_name>
# Example: https://kind-kind-dashboard.example.com
```

Retrieve the login token stored on the instance:

```bash
cat /home/ubuntu/configs/admin-user-token
```

Paste the token into the dashboard login screen.

### Tear Down

```bash
terraform destroy --auto-approve
```

This removes the EC2 instance and its associated resources. The VPC, ALB, Security Group, and Route 53 zone (which were pre-existing) are not deleted.

---

## Kubernetes Dashboard (Optional)

The Kubernetes Dashboard provides a browser-based UI for inspecting your cluster.

### Install the dashboard

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
```

### Create an admin service account

The `dashboard-adminuser.yml` manifest creates a `ServiceAccount` and binds it to the `cluster-admin` role:

```bash
kubectl apply -f dashboard-adminuser.yml
```

### Generate a login token

```bash
kubectl -n kubernetes-dashboard create token admin-user
```

Copy the token output — you will need it to log in.

### Access the dashboard

Start a port-forward in the background:

```bash
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard 8443:443 --address=0.0.0.0 &
```

Open your browser at `https://localhost:8443` and paste the token to log in.

> The dashboard uses a self-signed certificate so your browser will show a security warning — this is expected in a local lab environment. Click "Advanced" → "Proceed" to continue.

---

## NodePort Access

Ports `32000` through `32010` on the control-plane node are mapped directly to your host machine. When you deploy an application with a `NodePort` service in that range, you can reach it at `http://localhost:<port>`.

| Port | Reserved for |
|------|-------------|
| 32000 | Kubernetes Dashboard |
| 32001–32010 | Free for sample app deployments |

---

## Deploy a Sample Voting App (Optional)

A quick end-to-end validation of the cluster:

```bash
cd ~
git clone https://github.com/dockersamples/example-voting-app.git
cd example-voting-app
kubectl apply -f k8s-specifications/
kubectl get all
```

Access the apps via port-forward:

```bash
kubectl port-forward service/vote 5000:8080 --address=0.0.0.0 &
kubectl port-forward service/result 5001:8081 --address=0.0.0.0 &
```

- Vote at: `http://localhost:5000`
- Results at: `http://localhost:5001`

---

## File Reference

| File | Purpose |
|------|---------|
| `kind-config.yml` | KinD cluster topology (1 control-plane, 2 workers, NodePort mappings) |
| `Dockerfile` | Multi-stage image with kubectl, helm, terraform, kind, go |
| `docker-compose.yml` | Docker Compose service definition for the DinD environment |
| `entrypoint.sh` | Container startup script — creates cluster, installs CNI, inits helm/terraform |
| `dashboard-adminuser.yml` | ServiceAccount + ClusterRoleBinding for dashboard admin access |
| `install_docker.sh` | Installs Docker CE on Ubuntu (for VM/EC2 path) |
| `install_kind.sh` | Installs KinD binary on Ubuntu |
| `install_kubectl.sh` | Installs kubectl on Ubuntu |
| `install_helm.sh` | Installs Helm 3 on Ubuntu |
