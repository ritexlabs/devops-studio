# Kubernetes Ingress — Reference Manifests

An **Ingress** is a Kubernetes resource that routes external HTTP/HTTPS traffic to services inside your cluster. It acts as a single entry point and lets you define rules like "traffic to `/app` goes to service A" without exposing each service individually.

This directory contains ready-to-use manifest templates for the three most common ingress controllers: **Traefik**, **AWS ALB (EKS)**, and **GKE GCE**.

---

## Concepts at a Glance

```
Internet
   │
   ▼
Ingress Controller  ← installs once per cluster (Traefik, ALB, nginx, …)
   │
   ▼
Ingress Resource    ← your routing rules (this directory)
   │
   ├──► Service A  ──► Pod(s)
   └──► Service B  ──► Pod(s)
```

| Term | Meaning |
|------|---------|
| **Ingress Controller** | The actual software that reads Ingress rules and routes traffic (must be installed separately) |
| **Ingress Resource** | The YAML manifest that defines your routing rules |
| **IngressRoute** | Traefik's custom CRD alternative to the standard Ingress resource — more powerful |
| **Middleware** | Traefik-specific: pre/post-processing applied to requests (e.g., strip a path prefix) |

---

## Files in This Directory

| File | Controller | Use Case |
|------|-----------|----------|
| `traefik-ingress.yaml` | Traefik | Standard Kubernetes Ingress using Traefik annotations |
| `traefik-ingressRoute.yaml` | Traefik | Traefik CRD `IngressRoute` with TLS termination |
| `traefik-ingressRouteMiddleware.yaml` | Traefik | `IngressRoute` + `Middleware` to strip a URL path prefix |
| `eks-alb-ingress.yaml` | AWS ALB | EKS internet-facing ALB with HTTPS via ACM certificate |
| `gke-gce-ingress.yaml` | GKE GCE | GKE HTTP(S) Load Balancer with a static global IP |

---

## Traefik Ingress

### Option 1 — Standard Kubernetes Ingress (`traefik-ingress.yaml`)

Use this when you want a simple path-based or host-based rule and your cluster already has Traefik installed.

**What it does:** Routes all traffic from `<fqdn_hostname>/` to port 80 of `service-name` in the `app-ns` namespace. Traefik adds sticky session cookies.

**Steps:**

1. Ensure Traefik is installed in your cluster (comes pre-installed in KinD if you deploy it via Helm):
   ```bash
   helm repo add traefik https://traefik.github.io/charts
   helm repo update
   helm install traefik traefik/traefik
   ```

2. Edit `traefik-ingress.yaml` — replace placeholder values:
   - `<fqdn_hostname>` → your domain or `localhost`
   - `app-ns` → your app's namespace
   - `service-name` → your Kubernetes service name

3. Apply the manifest:
   ```bash
   kubectl apply -f traefik-ingress.yaml
   ```

4. Verify:
   ```bash
   kubectl get ingress -n app-ns
   ```

---

### Option 2 — Traefik IngressRoute CRD (`traefik-ingressRoute.yaml`)

Use this when you need TLS termination or more advanced routing features. Requires Traefik's CRDs to be installed (done automatically when installing via Helm).

**What it does:** Routes traffic matching the hostname rule to your service on both HTTP and HTTPS. TLS is terminated at Traefik using a Kubernetes Secret.

**Steps:**

1. Create a TLS secret (from a real certificate or self-signed for testing):
   ```bash
   # Self-signed certificate for local testing
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
     -keyout tls.key -out tls.crt -subj "/CN=localhost"

   kubectl create secret tls <tlssecretname> \
     --cert=tls.crt --key=tls.key -n app-ns
   ```

2. Edit `traefik-ingressRoute.yaml` — replace placeholder values:
   - `<fqdn_hostname>` → your domain
   - `app-ns` → your namespace
   - `app-name` → your service name
   - `<tlssecretname>` → name of the TLS secret created above

3. Apply the manifest:
   ```bash
   kubectl apply -f traefik-ingressRoute.yaml
   ```

---

### Option 3 — IngressRoute with Middleware (`traefik-ingressRouteMiddleware.yaml`)

Use this when your app is mounted at a sub-path (e.g., `/someone`) but expects requests at the root path `/`.

**What it does:** Strips the `/someone` prefix before forwarding requests to the backend service. Example: a browser request to `http://example.com/someone/page` arrives at your app as `/page`.

**Steps:**

1. Edit `traefik-ingressRouteMiddleware.yaml` — replace:
   - `/someone` → your actual path prefix
   - `<hostname>` → your domain
   - `app-ns`, `app-name`, `<tlssecretname>` → as above

2. Apply:
   ```bash
   kubectl apply -f traefik-ingressRouteMiddleware.yaml
   ```

3. Verify both resources were created:
   ```bash
   kubectl get middleware -n app-ns
   kubectl get ingressroute -n app-ns
   ```

---

## AWS EKS — ALB Ingress (`eks-alb-ingress.yaml`)

Use this on an EKS cluster with the [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/) installed.

**What it does:** Creates an internet-facing Application Load Balancer (ALB) that terminates HTTPS using an ACM certificate and forwards traffic to `app-service` on port 80.

**Prerequisites:**

- EKS cluster with the AWS Load Balancer Controller installed
- An ACM certificate issued for your domain

**Steps:**

1. Edit `eks-alb-ingress.yaml` — replace:
   - `app-ns` → your namespace
   - `<awsaccount>` → your 12-digit AWS account ID
   - `xxxx` → your ACM certificate ID (from the ACM console)
   - `<fqdn_hostname>` → your fully-qualified domain name (e.g., `myapp.example.com`)
   - `app-service` → your Kubernetes service name

2. Apply:
   ```bash
   kubectl apply -f eks-alb-ingress.yaml
   ```

3. Get the ALB DNS name (takes ~2 minutes to provision):
   ```bash
   kubectl get ingress app-ingress -n app-ns
   ```

4. Create a CNAME record in your DNS pointing `<fqdn_hostname>` to the ALB DNS name.

---

## GKE — GCE Ingress (`gke-gce-ingress.yaml`)

Use this on a GKE cluster to create a Google Cloud HTTP(S) Load Balancer.

**What it does:** Creates a GCE load balancer using a pre-reserved static IP and routes traffic to `service-red` in the `red-app` namespace.

**Prerequisites:**

- GKE cluster (GCE Ingress controller is built in)
- A reserved global static IP in GCP

**Steps:**

1. Reserve a static IP (if you haven't already):
   ```bash
   gcloud compute addresses create my-static-ip --global
   ```

2. Edit `gke-gce-ingress.yaml` — replace:
   - `red-app` → your namespace
   - `<static-ip-name>` → the name you used above (e.g., `my-static-ip`)
   - `<fqdn_hostname>` → your domain
   - `service-red` → your service name

3. Apply:
   ```bash
   kubectl apply -f gke-gce-ingress.yaml
   ```

4. Wait for the load balancer to be provisioned (~5 minutes):
   ```bash
   kubectl get ingress redapp-ingress -n red-app --watch
   ```

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `ADDRESS` column is empty | Controller not installed or pending | Check controller pods: `kubectl get pods -n kube-system` |
| 404 from the ingress | Path or service name mismatch | Double-check `path`, `service.name`, `service.port` |
| TLS handshake fails | Wrong or missing secret | Verify secret: `kubectl get secret <name> -n <ns>` |
| ALB not created on EKS | LB Controller not installed | Follow the [AWS LB Controller install guide](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.7/deploy/installation/) |
