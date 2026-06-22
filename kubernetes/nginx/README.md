# nginx — Simple Kubernetes Deployment

A minimal nginx web server. This is the recommended **first app to deploy** when learning Kubernetes — it demonstrates the four core resource types every app needs: Namespace, Deployment, Service, and Ingress.

---

## What Gets Deployed

| Resource | Name | Detail |
|----------|------|--------|
| Namespace | `nginx-demo` | Isolates all nginx resources |
| Deployment | `nginx-deploy` | 2 replicas of `nginx:1.23` from AWS ECR public |
| Service | `nginx-service` | NodePort — makes pods reachable inside and outside the cluster |
| Ingress | `nginx-ingress` | Traefik routes path `/nginx` to `nginx-service` |

**Image:** `public.ecr.aws/nginx/nginx:1.23`  
**Container port:** `80`

---

## Prerequisites

- A running Kubernetes cluster (KinD locally, or any cloud-managed cluster)
- `kubectl` configured — `kubectl get nodes` should return nodes in `Ready` state
- Traefik installed (required for the Ingress to function)

Install Traefik with Helm if it is not already running:

```bash
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm install traefik traefik/traefik
```

---

## Deploy

One command deploys all four resources:

```bash
kubectl apply -f ./nginx/
```

Or step through each file to understand what each resource does:

```bash
kubectl apply -f create-namespace.yaml   # Step 1: create the nginx-demo namespace
kubectl apply -f create-deployment.yaml  # Step 2: launch 2 nginx pods
kubectl apply -f create-service.yaml     # Step 3: expose pods via NodePort
kubectl apply -f create-ingress.yaml     # Step 4: create the /nginx route in Traefik
```

---

## Verify

```bash
kubectl get all -n nginx-demo
```

Expected output:

```
NAME                                READY   STATUS    RESTARTS   AGE
pod/nginx-deploy-6d4cf56db6-abc12   1/1     Running   0          30s
pod/nginx-deploy-6d4cf56db6-xyz34   1/1     Running   0          30s

NAME                    TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
service/nginx-service   NodePort   10.96.12.34   <none>        80:3xxxx/TCP   30s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deploy   2/2     2            2           30s
```

Check the ingress rule:

```bash
kubectl get ingress -n nginx-demo
```

---

## Access the Application

### Via Traefik Ingress

```
http://localhost/nginx
```

You should see the nginx "Welcome to nginx!" page.

### Via port-forward (no ingress needed)

```bash
kubectl port-forward svc/nginx-service 8080:80 -n nginx-demo
```

Then open `http://localhost:8080`.

### Via NodePort

```bash
kubectl get svc nginx-service -n nginx-demo
# Note the NodePort (the number after 80: in the PORT column)
```

Access at `http://localhost:<nodeport>`.

---

## Explore

```bash
# View pod details and events
kubectl describe pod <pod-name> -n nginx-demo

# Stream logs
kubectl logs -f <pod-name> -n nginx-demo

# Scale to 5 replicas
kubectl scale deployment nginx-deploy --replicas=5 -n nginx-demo

# Roll back the last update
kubectl rollout undo deployment/nginx-deploy -n nginx-demo
```

---

## Remove

```bash
kubectl delete -f ./nginx/
```

Removes the Ingress, Service, Deployment, and Namespace.

---

## TLS Ingress (Next Step)

To serve nginx over HTTPS via Traefik, see [nginx-ingress-dns](../nginx-ingress-dns/README.md).

---

## File Reference

| File | Purpose |
|------|---------|
| `create-namespace.yaml` | Creates the `nginx-demo` namespace |
| `create-deployment.yaml` | 2 replicas of `nginx:1.23`, container port 80 |
| `create-service.yaml` | NodePort service — cluster port 80 → container port 80 |
| `create-ingress.yaml` | Traefik Ingress routing `/nginx` → `nginx-service:80` |
