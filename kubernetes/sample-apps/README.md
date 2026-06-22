# Sample Applications

A collection of deployable sample applications for learning and exploring Kubernetes concepts. Each app demonstrates a core deployment pattern — from the simplest possible deployment to cloud-native ingress with DNS and TLS.

---

## Directory Overview

```
sample-apps/
├── nginx/                  # Minimal nginx deployment — best first app to deploy
├── nginx-ingress-dns/      # Traefik TLS ingress variant for nginx
├── colorapp/               # Color-themed Python/Flask app — explore env vars & replicas
└── colorapp-ingress-dns/   # Cloud ingress variants for colorapp (EKS ALB, GKE)
```

---

## Recommended Learning Order

| Order | Directory | Kubernetes Concepts Covered |
|-------|-----------|----------------------------|
| 1 | `nginx/` | Namespace, Deployment, Service (NodePort), Ingress |
| 2 | `colorapp/` | Environment variables, replica sets, path-based routing |
| 3 | `nginx-ingress-dns/` | Traefik IngressRoute CRD, TLS termination |
| 4 | `colorapp-ingress-dns/` | Cloud load balancers (EKS ALB, GKE GCE), ACM certificates |

---

## Common kubectl Commands for All Apps

```bash
# Deploy all manifests in a folder
kubectl apply -f ./<app-folder>/

# Check what was created
kubectl get all -n <namespace>

# Follow logs of a pod
kubectl logs -f <pod-name> -n <namespace>

# Remove everything deployed from a folder
kubectl delete -f ./<app-folder>/
```

---

## App Summaries

### nginx

A vanilla nginx web server. Use this as your very first Kubernetes deployment — it introduces the four core resource types every app needs: Namespace, Deployment, Service, and Ingress.

- Image: `public.ecr.aws/nginx/nginx:1.23`
- Namespace: `nginx-demo`
- Access via Traefik ingress at path `/nginx`

See [nginx/README.md](./nginx/README.md) for full instructions.

---

### colorapp

A Python/Flask web application that displays the color set in the `APP_COLOR` environment variable alongside the hostname of the pod serving the request. This makes it easy to see which pod is handling each request when multiple replicas are running.

- Image: `ritexlabs/colorapp:1.0.0`
- Namespace: `blue-app`
- Default color: `blue` (change the `APP_COLOR` env var to any CSS color name)
- Access via Traefik ingress at path `/blue`

See [colorapp/README.md](./colorapp/README.md) for full instructions.

---

### colorapp-ingress-dns

Cloud-specific Ingress manifests for the colorapp. Use these after you have deployed colorapp on a cloud-managed Kubernetes cluster and want to expose it publicly via DNS + HTTPS.

- `eks-alb-colorapp-ssl.yaml` — EKS Application Load Balancer with ACM SSL certificate
- `gke-gatway-colorapp.yaml` — GKE HTTP(S) Load Balancer with a global static IP

See [colorapp-ingress-dns/README.md](./colorapp-ingress-dns/README.md) for full instructions.

---

### nginx-ingress-dns

A Traefik `IngressRoute` (CRD) manifest for the nginx app with TLS support. Use this when you want to serve nginx over HTTPS via Traefik on any cluster.

See [nginx-ingress-dns/README.md](./nginx-ingress-dns/README.md) for full instructions.
