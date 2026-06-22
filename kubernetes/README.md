# Kubernetes Learning Lab

A curated collection of Kubernetes manifests, cluster setup scripts, and sample application deployments designed for hands-on learning and exploration. All examples are beginner-friendly and include step-by-step instructions.

## Directory Structure

```
kubernetes/
├── KinD-cluster/          # Local multi-node Kubernetes cluster using KinD + Docker
├── ingress/               # Ingress manifest templates for Traefik, EKS ALB, and GKE
├── persistant-storage/    # Persistent Volume and PVC examples
├── sample-apps/           # Deployable sample applications
│   ├── colorapp/          # Color-themed Python/Flask web app
│   ├── colorapp-ingress-dns/  # Cloud ingress variants for colorapp (EKS, GKE)
│   ├── nginx/             # Simple nginx deployment
│   └── nginx-ingress-dns/ # Traefik TLS ingress for nginx
└── utilities/             # Helper manifests (curl utility pod, etc.)
```

## Where to Start

If you are brand new to Kubernetes, follow this recommended learning path:

| Step | Directory | What You Learn |
|------|-----------|----------------|
| 1 | [KinD-cluster](./KinD-cluster/) | Set up a local 3-node cluster in Docker |
| 2 | [sample-apps/nginx](./sample-apps/nginx/) | Deploy your first app — namespace, deployment, service |
| 3 | [sample-apps/colorapp](./sample-apps/colorapp/) | Deploy a stateful-looking app and explore environment variables |
| 4 | [persistant-storage](./persistant-storage/) | Attach persistent volumes so data survives pod restarts |
| 5 | [ingress](./ingress/) | Route external HTTP/HTTPS traffic into your cluster |
| 6 | [utilities](./utilities/) | Debug network connectivity from inside the cluster |

## Prerequisites

- Docker Desktop (Mac/Windows) or Docker Engine (Linux)
- `kubectl` CLI — [install guide](https://kubernetes.io/docs/tasks/tools/)
- `kind` CLI — [install guide](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- Basic familiarity with the command line

> For cloud deployments (EKS, GKE) you will additionally need the respective cloud CLI and a running cluster.

## Quick Reference — Common kubectl Commands

```bash
# Cluster health
kubectl cluster-info
kubectl get nodes

# List resources
kubectl get pods -A                   # all pods in all namespaces
kubectl get all -n <namespace>        # everything in a namespace

# Apply / delete manifests
kubectl apply -f <file-or-folder>
kubectl delete -f <file-or-folder>

# Debug
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- bash
```
