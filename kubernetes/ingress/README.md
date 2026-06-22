# Kubernetes Ingress — Reference Manifests

An **Ingress** routes external HTTP/HTTPS traffic to services inside your cluster through a single entry point. Instead of exposing each service with its own load balancer, you define routing rules (host, path) in an Ingress resource and a single **Ingress Controller** enforces them.

---

## How It Works

```
Internet
   │
   ▼
Ingress Controller  ← installed once per cluster (Traefik, ALB, GCE, …)
   │
   ├── rule: /app  ──► Service A ──► Pods
   └── rule: /api  ──► Service B ──► Pods
```

| Term | What it is |
|------|-----------|
| **Ingress Controller** | The software that reads Ingress rules and handles traffic (must be installed separately) |
| **Ingress Resource** | The YAML manifest with your routing rules (what this directory contains) |
| **IngressRoute** | Traefik's CRD alternative to standard Ingress — more powerful |
| **Middleware** | Traefik-specific transform applied before routing (e.g. strip a path prefix) |

---

## Files in This Directory

| File | Controller | Use Case |
|------|-----------|----------|
| `traefik-ingress.yaml` | Traefik | Standard `networking.k8s.io/v1` Ingress with Traefik annotations |
| `traefik-ingressRoute.yaml` | Traefik | CRD `IngressRoute` with TLS termination |
| `traefik-ingressRouteMiddleware.yaml` | Traefik | `IngressRoute` + `Middleware` for path-prefix stripping |
| `eks-alb-ingress.yaml` | AWS ALB | EKS internet-facing ALB with HTTPS via ACM certificate |
| `gke-gce-ingress.yaml` | GKE GCE | GKE HTTP(S) load balancer with a reserved static IP |

---

## Traefik — Standard Ingress (`traefik-ingress.yaml`)

Routes traffic from `<fqdn_hostname>/` to `service-name` in `app-ns`. Enables sticky sessions via cookies.

### Install Traefik (if not already installed)

```bash
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm install traefik traefik/traefik
```

### Apply

1. Edit `traefik-ingress.yaml` — replace `<fqdn_hostname>`, `app-ns`, and `service-name`.
2. Apply:
   ```bash
   kubectl apply -f traefik-ingress.yaml
   kubectl get ingress -n app-ns
   ```

---

## Traefik — IngressRoute CRD (`traefik-ingressRoute.yaml`)

Use when you need TLS termination or host-based rules beyond what the standard Ingress supports. Requires Traefik's CRDs (installed automatically with the Helm chart).

### Create a TLS secret

For local testing, generate a self-signed certificate:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt -subj "/CN=localhost"

kubectl create secret tls <tlssecretname> \
  --cert=tls.crt --key=tls.key -n app-ns
```

### Apply

1. Edit `traefik-ingressRoute.yaml` — replace `<fqdn_hostname>`, `app-ns`, `app-name`, `<tlssecretname>`.
2. Apply:
   ```bash
   kubectl apply -f traefik-ingressRoute.yaml
   kubectl get ingressroute -n app-ns
   ```

---

## Traefik — IngressRoute with Middleware (`traefik-ingressRouteMiddleware.yaml`)

Use when your app lives at a sub-path (e.g. `/someone`) but expects requests at `/`.

**Example:** browser sends `http://example.com/someone/page` → app receives `/page`.

### Apply

1. Edit the manifest — replace `/someone`, `<hostname>`, `app-ns`, `app-name`, `<tlssecretname>`.
2. Apply:
   ```bash
   kubectl apply -f traefik-ingressRouteMiddleware.yaml
   kubectl get middleware,ingressroute -n app-ns
   ```

---

## AWS EKS — ALB Ingress (`eks-alb-ingress.yaml`)

Creates an internet-facing Application Load Balancer that terminates HTTPS via an ACM certificate.

### Prerequisites

- EKS cluster with [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/) installed
- An ACM certificate issued for your domain

### Apply

1. Edit `eks-alb-ingress.yaml`:
   - Replace `app-ns` with your namespace
   - Replace `<awsaccount>` with your 12-digit AWS account ID
   - Replace `xxxx` with your ACM certificate ID
   - Replace `<fqdn_hostname>` with your domain (e.g. `myapp.example.com`)
   - Replace `app-service` with your Kubernetes service name

2. Apply and wait for the ALB (1–3 minutes):
   ```bash
   kubectl apply -f eks-alb-ingress.yaml
   kubectl get ingress app-ingress -n app-ns
   ```

3. Create a DNS CNAME pointing your domain to the ALB address shown in the `ADDRESS` column.

---

## GKE — GCE Ingress (`gke-gce-ingress.yaml`)

Creates a Google Cloud HTTP(S) Load Balancer using a pre-reserved global static IP.

### Prerequisites

- GKE cluster (GCE Ingress is built in — no install needed)
- A reserved global static IP

```bash
gcloud compute addresses create my-static-ip --global
```

### Apply

1. Edit `gke-gce-ingress.yaml`:
   - Replace `red-app` with your namespace
   - Replace `<static-ip-name>` with the name used above
   - Replace `<fqdn_hostname>` with your domain
   - Replace `service-red` with your service name

2. Apply and wait for the load balancer (~5 minutes):
   ```bash
   kubectl apply -f gke-gce-ingress.yaml
   kubectl get ingress redapp-ingress -n red-app --watch
   ```

3. Create a DNS A record pointing your domain to the static IP.

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `ADDRESS` column empty | Controller not running or pending | `kubectl get pods -n kube-system` — check controller pod status |
| 404 from the ingress | Path or service name mismatch | Verify `path`, `service.name`, `service.port` in the manifest |
| TLS handshake failure | Missing or wrong secret | `kubectl get secret <name> -n <ns>` |
| ALB not created on EKS | LB Controller missing | Follow the [AWS LB Controller install guide](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.7/deploy/installation/) |
| GKE ingress stuck pending | Static IP name mismatch | Check `kubernetes.io/ingress.global-static-ip-name` annotation value |
