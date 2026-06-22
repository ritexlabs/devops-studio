# Color App — Sample Kubernetes Deployment

A Python/Flask web application that displays a colored page and the hostname of the pod serving the request. Because each pod shows its own hostname, refreshing the page when multiple replicas are running lets you watch Kubernetes load balancing in real time.

The color is set with an environment variable (`APP_COLOR`), so you can deploy multiple instances with different colors to explore namespacing and path routing.

---

## What Gets Deployed

| Resource | Name | Detail |
|----------|------|--------|
| Namespace | `blue-app` | Isolates all colorapp resources |
| Deployment | `deployment-blue` | 2 replicas of `ritexlabs/colorapp:1.0.0` |
| Service | `service-blue` | NodePort — exposes container port 8080 on cluster port 80 |
| Ingress | `ingress-blue` | Traefik routes path `/blue` to `service-blue` |

**Image:** `ritexlabs/colorapp:1.0.0`  
**Container port:** `8080`  
**Default color:** `blue` (set via `APP_COLOR` environment variable)

---

## Prerequisites

- A running Kubernetes cluster (KinD locally, or cloud-managed)
- `kubectl` configured — `kubectl get nodes` should return `Ready` nodes
- Traefik installed (required for the Ingress to work)

---

## Deploy

Deploy all four manifests at once:

```bash
kubectl apply -f ./colorapp/
```

Or step through each file:

```bash
kubectl apply -f create-namespace.yaml   # create the blue-app namespace
kubectl apply -f create-deployment.yaml  # launch 2 pods with APP_COLOR=blue
kubectl apply -f create-service.yaml     # expose pods via NodePort
kubectl apply -f create-ingress.yaml     # create the /blue route in Traefik
```

---

## Verify

```bash
kubectl get all -n blue-app
```

Expected output:

```
NAME                                    READY   STATUS    RESTARTS   AGE
pod/deployment-blue-7d9c5b6c8f-abc12   1/1     Running   0          30s
pod/deployment-blue-7d9c5b6c8f-xyz34   1/1     Running   0          30s

NAME                   TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/service-blue   NodePort   10.96.50.123   <none>        80:3xxxx/TCP   30s

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/deployment-blue  2/2     2            2           30s
```

---

## Access the Application

### Via Traefik Ingress

```
http://localhost/blue
```

The page shows a blue background and the pod hostname.

### Via port-forward

```bash
kubectl port-forward svc/service-blue 8080:80 -n blue-app
```

Then open `http://localhost:8080`.

---

## Change the Color

Edit `create-deployment.yaml` before applying:

```yaml
env:
- name: "APP_COLOR"
  value: "green"    # try: red, green, purple, orange, teal, …
```

Re-apply to update the running deployment:

```bash
kubectl apply -f create-deployment.yaml
```

---

## See Load Balancing in Action

Scale to more replicas, then refresh the browser several times — the hostname on the page changes between pod names:

```bash
kubectl scale deployment deployment-blue --replicas=4 -n blue-app
kubectl get pods -n blue-app   # 4 pods now running
```

Each refresh may be served by a different pod.

---

## Remove

```bash
kubectl delete -f ./colorapp/
```

Removes everything including the namespace.

---

## Cloud Ingress (EKS / GKE)

To expose colorapp publicly over HTTPS on a cloud cluster, see [colorapp-ingress-dns](../colorapp-ingress-dns/README.md).

For Helm chart and Terraform deployment options, see the [chart-shelf colorapp chart](https://github.com/ritexlabs/chart-shelf/tree/main/colorapp).

---

## File Reference

| File | Purpose |
|------|---------|
| `create-namespace.yaml` | Creates the `blue-app` namespace |
| `create-deployment.yaml` | 2 replicas of `ritexlabs/colorapp:1.0.0`, `APP_COLOR=blue`, port 8080 |
| `create-service.yaml` | NodePort service — cluster port 80 → container port 8080 |
| `create-ingress.yaml` | Traefik Ingress routing `/blue` → `service-blue:80` |
