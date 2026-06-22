# Color App — Cloud Ingress with DNS (EKS ALB & GKE)

Cloud-specific Ingress manifests for exposing the colorapp publicly via DNS and HTTPS on managed Kubernetes clusters. Use these **after** you have already deployed the colorapp base manifests (`../colorapp/`).

---

## Files in This Directory

| File | Cloud | What It Creates |
|------|-------|----------------|
| `eks-alb-colorapp-ssl.yaml` | AWS EKS | Namespace + Deployment + NodePort Service + ALB Ingress with HTTPS |
| `gke-gatway-colorapp.yaml` | GCP GKE | GCE HTTP(S) Load Balancer Ingress with a global static IP |

---

## Option 1 — AWS EKS with Application Load Balancer (ALB)

### What It Does

`eks-alb-colorapp-ssl.yaml` is a single all-in-one manifest that creates:
- The `blue-app` namespace
- A `deployment-blue` Deployment (2 replicas of `ritexlabs/colorapp:1.0.0`)
- A `service-blue` NodePort Service
- A `blueapp-ingress` ALB Ingress that listens on HTTPS port 443 using an ACM certificate

Traffic flow:

```
Internet ──► Route 53 / DNS ──► AWS ALB (HTTPS:443) ──► service-blue ──► pods
```

### Prerequisites

- An EKS cluster with the [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/) installed
- An ACM certificate issued (or validated) for your domain
- A domain name you control (to create a DNS CNAME record)

### Step 1 — Find your ACM certificate ARN

In the AWS Console, go to **Certificate Manager** → select your certificate → copy the ARN. It looks like:

```
arn:aws:acm:us-east-1:123456789012:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### Step 2 — Edit the manifest

Open `eks-alb-colorapp-ssl.yaml` and replace these placeholders:

| Placeholder | Replace With |
|-------------|-------------|
| `<ACM-SSL Certificate ARN>` | Your full ACM certificate ARN |
| `blueapp.example.com` | Your actual domain (e.g., `colorapp.mycompany.com`) |

### Step 3 — Deploy

```bash
kubectl apply -f eks-alb-colorapp-ssl.yaml
```

### Step 4 — Wait for the ALB to provision

ALB creation takes 1–3 minutes:

```bash
kubectl get ingress blueapp-ingress -n blue-app --watch
```

Once the `ADDRESS` column shows a DNS name (e.g., `k8s-blueapp-xxxx.us-east-1.elb.amazonaws.com`), the ALB is ready.

### Step 5 — Create a DNS record

In Route 53 (or your DNS provider), create a CNAME record:

```
colorapp.mycompany.com  →  k8s-blueapp-xxxx.us-east-1.elb.amazonaws.com
```

Wait for DNS propagation (usually a few minutes), then open:

```
https://colorapp.mycompany.com
```

### Remove

```bash
kubectl delete -f eks-alb-colorapp-ssl.yaml
```

---

## Option 2 — GKE with GCE HTTP(S) Load Balancer

### What It Does

`gke-gatway-colorapp.yaml` creates a GKE Ingress backed by a Google Cloud HTTP(S) Load Balancer. It uses a pre-reserved global static IP, which you point your DNS CNAME at.

Traffic flow:

```
Internet ──► DNS ──► GCP Global HTTP(S) LB (static IP) ──► service-blue ──► pods
```

### Prerequisites

- A GKE cluster (GCE Ingress controller is built in — no additional install needed)
- The colorapp base Deployment and Service deployed (`../colorapp/`)
- A reserved global static IP in GCP
- A domain name you control

> **Note:** This manifest only contains the Ingress resource. Deploy the base app first:
> ```bash
> kubectl apply -f ../colorapp/create-namespace.yaml
> kubectl apply -f ../colorapp/create-deployment.yaml
> kubectl apply -f ../colorapp/create-service.yaml
> ```

### Step 1 — Reserve a static IP

```bash
gcloud compute addresses create colorapp-static-ip --global
gcloud compute addresses describe colorapp-static-ip --global
# Note the IP address shown
```

### Step 2 — Edit the manifest

Open `gke-gatway-colorapp.yaml` and replace:

| Placeholder | Replace With |
|-------------|-------------|
| `examplelabs-webapps-ip` | The name you used in Step 1 (e.g., `colorapp-static-ip`) |
| `blueapp.example.com` | Your actual domain |

### Step 3 — Deploy the Ingress

```bash
kubectl apply -f gke-gatway-colorapp.yaml
```

### Step 4 — Wait for the load balancer

GKE load balancer provisioning takes 3–10 minutes:

```bash
kubectl get ingress blueapp-ingress -n blue-app --watch
```

Once the `ADDRESS` column shows the static IP, the load balancer is ready.

### Step 5 — Create a DNS A record

In your DNS provider, create an A record pointing your domain to the static IP:

```
colorapp.mycompany.com  →  <static IP from Step 1>
```

Then open:

```
http://colorapp.mycompany.com
```

> GKE GCE Ingress serves HTTP by default. To add HTTPS, configure a managed SSL certificate via GCP or use a `FrontendConfig` resource.

### Remove

```bash
kubectl delete -f gke-gatway-colorapp.yaml
```

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| ALB `ADDRESS` stays empty | LB controller not installed or IAM issue | Check pods: `kubectl get pods -n kube-system \| grep aws-load-balancer` |
| HTTPS returns cert error | ACM cert not validated or wrong ARN | Verify cert status in ACM console |
| GKE Ingress stuck pending | Static IP name mismatch | Double-check `kubernetes.io/ingress.global-static-ip-name` annotation |
| Site unreachable after DNS | DNS not propagated yet | Wait 5–10 min, then `dig colorapp.mycompany.com` |
