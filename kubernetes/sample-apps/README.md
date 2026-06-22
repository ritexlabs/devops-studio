# Sample Applications

Deployable sample apps for exploring Kubernetes concepts step by step. Each app focuses on one pattern — from the simplest possible deployment to cloud-native ingress with DNS and TLS.

---

## Directory Layout

```
sample-apps/
├── nginx/                  # Minimal nginx — best first app to deploy on Kubernetes
├── nginx-ingress-dns/      # Traefik IngressRoute with TLS for nginx
├── colorapp/               # Python/Flask color app — env vars, replicas, path routing
└── colorapp-ingress-dns/   # Cloud ingress for colorapp (EKS ALB + GKE)
```

---

## Recommended Order

| Step | App | Kubernetes Concepts |
|------|-----|---------------------|
| 1 | [nginx](./nginx/) | Namespace, Deployment, Service (NodePort), Ingress |
| 2 | [colorapp](./colorapp/) | Environment variables, replica sets, path-based routing |
| 3 | [nginx-ingress-dns](./nginx-ingress-dns/) | Traefik IngressRoute CRD, TLS secret, sticky sessions |
| 4 | [colorapp-ingress-dns](./colorapp-ingress-dns/) | Cloud load balancers — EKS ALB with ACM, GKE GCE with static IP |

---

## Common Commands

```bash
# Deploy all manifests in a folder at once
kubectl apply -f ./<app>/

# Check everything deployed in a namespace
kubectl get all -n <namespace>

# Stream pod logs
kubectl logs -f <pod-name> -n <namespace>

# Remove everything deployed from a folder
kubectl delete -f ./<app>/
```
