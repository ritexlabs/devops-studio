# nginx — Simple Kubernetes Deployment

A minimal nginx web server deployment. This is the recommended **first app to deploy** when learning Kubernetes because it clearly demonstrates the four core resource types every application needs: Namespace, Deployment, Service, and Ingress.

---

## What Gets Deployed

| Resource | Name | Details |
|----------|------|---------|
| Namespace | `nginx-demo` | Isolates all nginx resources |
| Deployment | `nginx-deploy` | 2 replicas of nginx 1.23 |
| Service | `nginx-service` | NodePort — makes pods reachable inside and outside the cluster |
| Ingress | `nginx-ingress` | Traefik routes `/nginx` traffic to `nginx-service` |

**Container image:** `public.ecr.aws/nginx/nginx:1.23` (AWS ECR public mirror)  
**Container port:** `80`

---

## Prerequisites

- A running Kubernetes cluster (local KinD or cloud-managed)
- `kubectl` configured to point at your cluster (`kubectl get nodes` should return nodes in `Ready` state)
- Traefik installed in the cluster (required for the Ingress resource to route traffic)

To install Traefik on a KinD cluster:

```bash
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm install traefik traefik/traefik
```

---

## Deploy

Apply all four manifests with one command:

```bash
kubectl apply -f ./nginx/
```

Or step through them one file at a time to understand each resource:

```bash
kubectl apply -f create-namespace.yaml   # Step 1: create the nginx-demo namespace
kubectl apply -f create-deployment.yaml  # Step 2: launch 2 nginx pods
kubectl apply -f create-service.yaml     # Step 3: expose pods via NodePort
kubectl apply -f create-ingress.yaml     # Step 4: route /nginx through Traefik
```

---

## Verify the Deployment

```bash
kubectl get all -n nginx-demo
```

Expected output:

```
NAME                                READY   STATUS    RESTARTS   AGE
pod/nginx-deploy-6d4cf56db6-abc12   1/1     Running   0          30s
pod/nginx-deploy-6d4cf56db6-xyz34   1/1     Running   0          30s

NAME                    TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/nginx-service   NodePort   10.96.12.34    <none>        80:3xxxx/TCP   30s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deploy   2/2     2            2           30s
```

Check the ingress rule:

```bash
kubectl get ingress -n nginx-demo
```

---

## Access the Application

### Via Traefik Ingress (recommended)

With Traefik running and the ingress applied, nginx is accessible at:

```
http://localhost/nginx
```

You should see the nginx "Welcome to nginx!" page.

### Via NodePort (without ingress)

Find the NodePort assigned to the service:

```bash
kubectl get svc nginx-service -n nginx-demo
# Look for the port in the format 80:3XXXX/TCP
```

Access the app directly:

```
http://localhost:<nodeport>
```

### Via port-forward (simplest debugging method)

```bash
kubectl port-forward svc/nginx-service 8080:80 -n nginx-demo
```

Then open `http://localhost:8080` in your browser.

---

## Explore the Deployment

### Inspect a running pod

```bash
# List pods in the namespace
kubectl get pods -n nginx-demo

# View pod details including events
kubectl describe pod <pod-name> -n nginx-demo

# View nginx logs
kubectl logs <pod-name> -n nginx-demo
```

### Scale the deployment

```bash
kubectl scale deployment nginx-deploy --replicas=5 -n nginx-demo
kubectl get pods -n nginx-demo   # watch 5 pods come up
```

### Update the nginx image

Edit `create-deployment.yaml` and change the image tag, then re-apply:

```bash
# In create-deployment.yaml, change:
#   image: public.ecr.aws/nginx/nginx:1.23
# to:
#   image: public.ecr.aws/nginx/nginx:1.25

kubectl apply -f create-deployment.yaml
kubectl rollout status deployment/nginx-deploy -n nginx-demo
```

### Roll back an update

```bash
kubectl rollout undo deployment/nginx-deploy -n nginx-demo
```

---

## Remove the App

```bash
kubectl delete -f ./nginx/
```

This deletes the Ingress, Service, Deployment, and Namespace (and all pods in it).

---

## TLS Ingress (Advanced)

For serving nginx over HTTPS with Traefik using a TLS certificate, see the [nginx-ingress-dns](../nginx-ingress-dns/README.md) directory.

---

## File Reference

| File | Purpose |
|------|---------|
| `create-namespace.yaml` | Creates the `nginx-demo` namespace |
| `create-deployment.yaml` | Deploys 2 replicas of `nginx:1.23`, container port 80 |
| `create-service.yaml` | NodePort service forwarding cluster port 80 → container port 80 |
| `create-ingress.yaml` | Traefik Ingress routing path `/nginx` → `nginx-service` |
