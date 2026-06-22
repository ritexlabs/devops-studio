# Kubernetes Learning Lab

A curated collection of Kubernetes manifests, cluster setup guides, and sample app deployments — designed for hands-on learning. All examples are beginner-friendly and include step-by-step instructions.

---

## Directory Structure

```
kubernetes/
├── KinD-cluster/          # Local multi-node Kubernetes cluster (Docker Compose / VM / Terraform)
├── ingress/               # Ingress manifest templates — Traefik, EKS ALB, GKE
├── persistant-storage/    # PersistentVolume and PVC examples (local + AWS)
├── sample-apps/
│   ├── nginx/                 # First Kubernetes app — Namespace, Deployment, Service, Ingress
│   ├── colorapp/              # Python/Flask color app — env vars, replicas, load balancing
│   ├── colorapp-ingress-dns/  # Cloud ingress for colorapp (EKS ALB + GKE)
│   └── nginx-ingress-dns/     # Traefik TLS IngressRoute for nginx
└── utilities/             # In-cluster curl pod for connectivity debugging
```

---

## Recommended Learning Path

| Step | Directory | What You Learn |
|------|-----------|----------------|
| 1 | [KinD-cluster](./KinD-cluster/) | Spin up a local 3-node cluster in Docker |
| 2 | [sample-apps/nginx](./sample-apps/nginx/) | Deploy your first app — Namespace, Deployment, Service, Ingress |
| 3 | [sample-apps/colorapp](./sample-apps/colorapp/) | Explore env variables, replicas, and load balancing |
| 4 | [persistant-storage](./persistant-storage/) | Attach storage so data survives pod restarts |
| 5 | [ingress](./ingress/) | Route HTTP/HTTPS traffic into the cluster |
| 6 | [utilities](./utilities/) | Debug in-cluster networking with a curl pod |

---

## Prerequisites

- Docker Desktop (Mac/Windows) or Docker Engine (Linux)
- `kubectl` CLI — [install guide](https://kubernetes.io/docs/tasks/tools/)
- `kind` CLI — [install guide](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)

> Cloud deployments (EKS, GKE) additionally require the cloud CLI and a running managed cluster.

---

## Quick kubectl Reference

```bash
# Cluster health
kubectl cluster-info
kubectl get nodes

# List resources
kubectl get pods -A                    # all pods across all namespaces
kubectl get all -n <namespace>         # all resources in one namespace

# Apply / delete
kubectl apply -f <file-or-folder>
kubectl delete -f <file-or-folder>

# Debug
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
kubectl exec -it <pod-name> -n <namespace> -- bash
```
