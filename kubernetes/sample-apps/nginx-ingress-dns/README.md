# nginx — Traefik IngressRoute with TLS

A Traefik `IngressRoute` (CRD) manifest that serves the nginx deployment over HTTPS. Use this after you have deployed the base nginx app (`../nginx/`) and want to add TLS termination via Traefik.

---

## What Is in This Directory

| File | What It Creates |
|------|----------------|
| `create-ingress-tls.yaml` | Traefik `IngressRoute` with TLS for the `nginx-demo` namespace |

---

## Background — IngressRoute vs Standard Ingress

The standard Kubernetes `Ingress` resource (`../nginx/create-ingress.yaml`) works for simple HTTP routing. The Traefik `IngressRoute` CRD used here adds:

- **TLS termination** using a Kubernetes Secret containing your certificate
- **Sticky sessions** via cookies
- **Fine-grained host matching** using Traefik's rule syntax

---

## Prerequisites

- The base nginx deployment running: `../nginx/create-namespace.yaml`, `create-deployment.yaml`, `create-service.yaml` must already be applied
- Traefik installed via Helm (required for `IngressRoute` CRDs to exist)
- A TLS certificate as a Kubernetes Secret in the `nginx-demo` namespace

---

## Step 1 — Deploy the Base nginx App

If you haven't already:

```bash
kubectl apply -f ../nginx/create-namespace.yaml
kubectl apply -f ../nginx/create-deployment.yaml
kubectl apply -f ../nginx/create-service.yaml
```

Verify pods are running:

```bash
kubectl get pods -n nginx-demo
```

---

## Step 2 — Create a TLS Secret

You need a certificate and private key. For local testing, generate a self-signed certificate:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key \
  -out tls.crt \
  -subj "/CN=localhost/O=nginx-demo"
```

Create the Kubernetes Secret in the `nginx-demo` namespace:

```bash
kubectl create secret tls exampledev-tls \
  --cert=tls.crt \
  --key=tls.key \
  -n nginx-demo
```

Verify the secret was created:

```bash
kubectl get secret exampledev-tls -n nginx-demo
```

> For production, use a real certificate from a CA (e.g., Let's Encrypt with cert-manager, or an ACM certificate imported as a secret).

---

## Step 3 — Apply the IngressRoute

```bash
kubectl apply -f create-ingress-tls.yaml
```

Verify:

```bash
kubectl get ingressroute -n nginx-demo
```

Expected output:

```
NAME                  AGE
nginx-ingress-route   10s
```

---

## Step 4 — Access nginx over HTTPS

The `create-ingress-tls.yaml` manifest uses `Host(*)` which matches any hostname. Access nginx at:

```
https://localhost
```

> Your browser will warn about an untrusted certificate when using a self-signed cert. Click "Advanced" → "Proceed" to continue — this is expected in a local testing environment.

For a production setup, replace `Host(*)` in the manifest with your actual domain:

```yaml
match: Host(`nginx.mycompany.com`)
```

And replace the self-signed secret with a valid certificate.

---

## Manifest Explained

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: nginx-ingress-route
  namespace: nginx-demo
spec:
  tls:
    secretName: exampledev-tls    # the TLS secret you created above
  entryPoints:
    - web        # HTTP (port 80)
    - websecure  # HTTPS (port 443)
  routes:
    - kind: Rule
      match: Host(`*`)            # replace with your domain in production
      services:
        - kind: Service
          name: nginx-service
          namespace: nginx-demo
          port: 80
          sticky:
            cookie:
              httpOnly: true      # sticky session cookie settings
              name: cookie
              sameSite: none
              secure: true
```

---

## Remove

```bash
kubectl delete -f create-ingress-tls.yaml
kubectl delete secret exampledev-tls -n nginx-demo
```

To also remove the base nginx deployment:

```bash
kubectl delete -f ../nginx/
```

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `kubectl apply` fails with "no matches for kind IngressRoute" | Traefik CRDs not installed | Install Traefik via Helm first |
| Browser shows connection refused | Traefik not running or wrong entrypoint port | Check `kubectl get pods -n kube-system \| grep traefik` |
| Certificate warning in browser | Self-signed cert | Expected — click "Proceed" or use a real cert |
| 404 from Traefik | Service name or namespace mismatch | Verify `name: nginx-service` and `namespace: nginx-demo` in the manifest |
