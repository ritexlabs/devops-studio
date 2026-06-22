# Color App — Sample Kubernetes Deployment

A lightweight Python/Flask web application that displays a colored page with the pod's hostname. Because each pod shows its own hostname, this app makes it easy to see Kubernetes load balancing in action when you scale up replicas.

The app color is controlled by an environment variable (`APP_COLOR`), so you can deploy multiple instances in different colors to explore namespacing and routing.

---

## What Gets Deployed

| Resource | Name | Details |
|----------|------|---------|
| Namespace | `blue-app` | Isolates all resources for this app |
| Deployment | `deployment-blue` | 2 replicas of the colorapp container |
| Service | `service-blue` | NodePort — exposes the app within and outside the cluster |
| Ingress | `ingress-blue` | Traefik routes `/blue` traffic to `service-blue` |

**Container image:** `ritexlabs/colorapp:1.0.0`  
**Container port:** `8080`  
**Default color:** blue

---

## Prerequisites

- A running Kubernetes cluster (local KinD or cloud-managed)
- `kubectl` configured to point at your cluster (`kubectl get nodes` should work)
- Traefik installed in the cluster (required for the Ingress to work)

---

## Deploy

Apply all manifests in this directory at once:

```bash
kubectl apply -f ./colorapp/
```

Or apply each file step by step to understand what each resource does:

```bash
kubectl apply -f create-namespace.yaml   # creates the blue-app namespace
kubectl apply -f create-deployment.yaml  # launches 2 pods
kubectl apply -f create-service.yaml     # exposes pods via NodePort
kubectl apply -f create-ingress.yaml     # creates the /blue route in Traefik
```

---

## Verify the Deployment

```bash
# Check all resources in the namespace
kubectl get all -n blue-app
```

Expected output:

```
NAME                                    READY   STATUS    RESTARTS   AGE
pod/deployment-blue-7d9c5b6c8f-abc12   1/1     Running   0          30s
pod/deployment-blue-7d9c5b6c8f-xyz34   1/1     Running   0          30s

NAME                   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/service-blue   NodePort   10.96.50.123    <none>        80:3xxxx/TCP   30s

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/deployment-blue  2/2     2            2           30s
```

---

## Access the Application

### On a local KinD cluster

If Traefik is installed, the app is available at:

```
http://localhost/blue
```

To find the Traefik NodePort if accessing by node IP:

```bash
kubectl get svc -n kube-system | grep traefik
```

### Direct NodePort access (no ingress needed)

Find the NodePort assigned to the service:

```bash
kubectl get svc service-blue -n blue-app
```

Then access the app at:

```
http://localhost:<nodeport>
```

---

## Customise the App Color

The `APP_COLOR` environment variable controls the background color. Edit `create-deployment.yaml` before applying:

```yaml
env:
- name: "APP_COLOR"
  value: "green"    # change to: red, green, purple, orange, …
```

Re-apply after editing:

```bash
kubectl apply -f create-deployment.yaml
```

---

## Scale the Deployment

Increase the number of replicas to see load balancing in action. Refresh the browser multiple times — the hostname on the page will change between pod names:

```bash
kubectl scale deployment deployment-blue --replicas=4 -n blue-app
kubectl get pods -n blue-app   # see 4 pods running
```

---

## Remove the App

```bash
kubectl delete -f ./colorapp/
```

This removes all resources including the namespace, pods, service, and ingress.

---

## Cloud Ingress (EKS / GKE)

If you are running on a cloud-managed cluster and want to expose this app via DNS and HTTPS, see the [colorapp-ingress-dns](../colorapp-ingress-dns/README.md) directory for EKS ALB and GKE manifests.

For more deployment options including Helm and Terraform, see the [chart-shelf colorapp chart](https://github.com/ritexlabs/chart-shelf/tree/main/colorapp).

---

## File Reference

| File | Purpose |
|------|---------|
| `create-namespace.yaml` | Creates the `blue-app` namespace |
| `create-deployment.yaml` | Defines 2 replicas of `ritexlabs/colorapp:1.0.0` with `APP_COLOR=blue` |
| `create-service.yaml` | NodePort service exposing container port 8080 on cluster port 80 |
| `create-ingress.yaml` | Traefik Ingress routing `/blue` to `service-blue` |
