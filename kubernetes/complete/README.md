# Color App — Cloud Ingress with DNS (EKS ALB & GKE)

Cloud-specific Ingress manifests for exposing colorapp publicly with DNS and HTTPS. Use these **after** the base colorapp is already running on your cloud cluster.

---

## Files in This Directory

| File | Cloud | What It Creates |
|------|-------|----------------|
| `eks-alb-colorapp-ssl.yaml` | AWS EKS | Namespace + Deployment + NodePort Service + ALB Ingress (HTTPS via ACM) |
| `gke-gatway-colorapp.yaml` | GCP GKE | GCE HTTP(S) Load Balancer Ingress with a global static IP |

---

## Option 1 — AWS EKS with ALB + HTTPS

`eks-alb-colorapp-ssl.yaml` is an all-in-one manifest that creates the `blue-app` namespace, deployment, service, and an ALB Ingress that listens on HTTPS port 443 using an ACM certificate.

**Traffic flow:**
```
Browser → DNS → AWS ALB (HTTPS:443, ACM cert) → service-blue → pods
```

### Prerequisites

- EKS cluster with the [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/) installed
- An ACM certificate issued for your domain (in the same AWS region as the cluster)
- A domain name you control

### Step 1 — Find your ACM certificate ARN

In the AWS Console go to **Certificate Manager** → select the certificate for your domain → copy the full ARN:

```
arn:aws:acm:us-east-1:123456789012:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### Step 2 — Edit the manifest

Open `eks-alb-colorapp-ssl.yaml` and replace:

| Placeholder | Replace with |
|-------------|-------------|
| `<ACM-SSL Certificate ARN>` | Your ACM certificate ARN |
| `blueapp.example.com` | Your actual domain (e.g. `colorapp.mycompany.com`) |

### Step 3 — Deploy

```bash
kubectl apply -f eks-alb-colorapp-ssl.yaml
```

### Step 4 — Wait for the ALB to provision (1–3 minutes)

```bash
kubectl get ingress blueapp-ingress -n blue-app --watch
```

When the `ADDRESS` column shows an ALB DNS name (e.g. `k8s-blueapp-xxxx.us-east-1.elb.amazonaws.com`), the ALB is ready.

### Step 5 — Create a DNS CNAME record

In Route 53 (or your DNS provider):

```
colorapp.mycompany.com  →  k8s-blueapp-xxxx.us-east-1.elb.amazonaws.com   (CNAME)
```

Wait a few minutes for DNS to propagate, then open:

```
https://colorapp.mycompany.com
```

### Remove

```bash
kubectl delete -f eks-alb-colorapp-ssl.yaml
```

---

## Option 2 — GKE with GCE HTTP(S) Load Balancer

`gke-gatway-colorapp.yaml` creates a GCE Ingress backed by a Google Cloud HTTP(S) Load Balancer using a pre-reserved static IP.

**Traffic flow:**
```
Browser → DNS → GCP Global LB (static IP) → service-blue → pods
```

> This file contains only the Ingress resource. Deploy the base app first:
> ```bash
> kubectl apply -f ../colorapp/
> ```

### Prerequisites

- GKE cluster (GCE Ingress is built in — nothing extra to install)
- A reserved global static IP in GCP
- A domain you control

### Step 1 — Reserve a static IP

```bash
gcloud compute addresses create colorapp-static-ip --global
gcloud compute addresses describe colorapp-static-ip --global
# Note the IP address
```

### Step 2 — Edit the manifest

Open `gke-gatway-colorapp.yaml` and replace:

| Placeholder | Replace with |
|-------------|-------------|
| `examplelabs-webapps-ip` | The name used in Step 1 (`colorapp-static-ip`) |
| `blueapp.example.com` | Your actual domain |

### Step 3 — Deploy

```bash
kubectl apply -f gke-gatway-colorapp.yaml
```

### Step 4 — Wait for the load balancer (~5 minutes)

```bash
kubectl get ingress blueapp-ingress -n blue-app --watch
```

The `ADDRESS` column shows the static IP when ready.

### Step 5 — Create a DNS A record

```
colorapp.mycompany.com  →  <static IP>   (A record)
```

Then open `http://colorapp.mycompany.com`.

> GKE GCE Ingress serves HTTP by default. For HTTPS, configure a Google-managed SSL certificate via a `FrontendConfig` resource.

### Remove

```bash
kubectl delete -f gke-gatway-colorapp.yaml
```

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| ALB `ADDRESS` stays empty | LB Controller not installed or IAM permissions missing | `kubectl get pods -n kube-system \| grep aws-load-balancer` |
| HTTPS returns a cert error | ACM cert not validated or wrong ARN | Check cert status in the ACM console |
| GKE Ingress stays pending | Static IP name mismatch in annotation | Verify `kubernetes.io/ingress.global-static-ip-name` value |
| Site not reachable after DNS | DNS not propagated yet | Wait 5–10 min, then run `dig colorapp.mycompany.com` |
