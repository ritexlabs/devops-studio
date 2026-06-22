# nginx — Traefik IngressRoute with TLS

A Traefik `IngressRoute` (CRD) that serves the nginx deployment over HTTPS. Use this after you have deployed the base nginx app (`../nginx/`) and want to add TLS termination via Traefik.

---

## Files in This Directory

| File | What It Creates |
|------|----------------|
| `create-ingress-tls.yaml` | Traefik `IngressRoute` with TLS for the `nginx-demo` namespace |

---

## Standard Ingress vs IngressRoute

The standard Kubernetes Ingress in `../nginx/create-ingress.yaml` handles basic HTTP routing. The Traefik `IngressRoute` CRD used here adds:

- **TLS termination** using a Kubernetes Secret that holds your certificate
- **Sticky sessions** via cookies (`httpOnly`, `sameSite: none`, `secure: true`)
- **Traefik rule syntax** for more flexible host and path matching

---

## Prerequisites

- Base nginx app deployed: apply `../nginx/create-namespace.yaml`, `create-deployment.yaml`, `create-service.yaml` first
- Traefik installed via Helm (`IngressRoute` CRDs must be registered)
- A TLS certificate stored as a Kubernetes Secret in the `nginx-demo` namespace

---

## Step 1 — Deploy the Base nginx App

If not already running:

```bash
kubectl apply -f ../nginx/create-namespace.yaml
kubectl apply -f ../nginx/create-deployment.yaml
kubectl apply -f ../nginx/create-service.yaml

kubectl get pods -n nginx-demo   # wait for Running
```

---

## Step 2 — Create a TLS Secret

For **local / lab testing**, generate a self-signed certificate:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key \
  -out tls.crt \
  -subj "/CN=localhost/O=nginx-demo"

kubectl create secret tls exampledev-tls \
  --cert=tls.crt \
  --key=tls.key \
  -n nginx-demo

kubectl get secret exampledev-tls -n nginx-demo   # confirm created
```

For **production**, replace the self-signed cert with one from Let's Encrypt (cert-manager) or your CA.

---

## Step 3 — Apply the IngressRoute

```bash
kubectl apply -f create-ingress-tls.yaml
kubectl get ingressroute -n nginx-demo
```

Expected:

```
NAME                  AGE
nginx-ingress-route   10s
```

---

## Step 4 — Access nginx over HTTPS

The manifest matches `Host(*)` which accepts any hostname. Open:

```
https://localhost
```

> Your browser will show a security warning for the self-signed certificate. Click **Advanced → Proceed** to continue — this is expected in a local lab.

For a real domain in production, replace `Host(*)` in the manifest with your domain:

```yaml
match: Host(`nginx.mycompany.com`)
```

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
    secretName: exampledev-tls     # Kubernetes Secret with your cert and key
  entryPoints:
    - web                           # port 80
    - websecure                     # port 443
  routes:
    - kind: Rule
      match: Host(`*`)              # replace with your domain in production
      services:
        - kind: Service
          name: nginx-service
          namespace: nginx-demo
          passHostHeader: true
          port: 80
          sticky:
            cookie:
              httpOnly: true
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
| `no matches for kind IngressRoute` | Traefik CRDs not installed | Install Traefik via Helm first |
| Connection refused on 443 | Traefik not running or `websecure` entrypoint not exposed | `kubectl get pods -n kube-system \| grep traefik` |
| Browser cert warning | Self-signed certificate | Expected in lab — click Proceed, or use a real cert |
| 404 from Traefik | Service name or namespace mismatch | Confirm `name: nginx-service` and `namespace: nginx-demo` |
