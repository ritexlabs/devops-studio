# Kubernetes Utilities

Helper manifests for debugging and troubleshooting inside a Kubernetes cluster. These are not application deployments — they are on-demand tools you launch when you need to investigate something.

---

## Files

| File | What It Does |
|------|-------------|
| `launch-curlutils-pod.yaml` | Starts a pod with `curl` pre-installed for in-cluster HTTP testing |

---

## curl Utility Pod

### What It Is

`launch-curlutils-pod.yaml` runs the `curlimages/curl:8.12.1` image and sleeps for 3600 seconds (1 hour). This keeps the pod alive so you can `exec` into it and run `curl` commands against any endpoint reachable from within the cluster network — including **private ClusterIP addresses** and **internal DNS names** that are not accessible from your laptop.

### When to Use It

- Test whether a service is reachable from inside the cluster
- Verify internal DNS resolution (`nginx-service.nginx-demo`)
- Check health endpoints on ClusterIP services
- Diagnose network policies or service misconfiguration

---

## Step 1 — Launch the Pod

```bash
kubectl apply -f launch-curlutils-pod.yaml
kubectl get pod curlutils --watch
# Wait until STATUS shows Running
```

---

## Step 2 — Open a Shell and Run curl

```bash
kubectl exec -it curlutils -- sh
```

Inside the pod you have full cluster network access:

```sh
# Test a service by its internal DNS name  (format: <service>.<namespace>)
curl http://nginx-service.nginx-demo

# Test a ClusterIP service directly
curl http://10.96.12.34

# Check an HTTP health endpoint
curl -v http://my-app-service.my-namespace/health

# Follow redirects and print response headers
curl -Lv http://my-service.default

# Test HTTPS with a self-signed cert (-k skips cert verification)
curl -k https://my-secure-service.default

exit
```

---

## Step 3 — Remove When Done

The pod lives for 1 hour then the sleep exits and it completes. Remove it manually when finished:

```bash
kubectl delete -f launch-curlutils-pod.yaml
```

---

## Tips

### Internal DNS format

Kubernetes DNS follows the pattern `<service>.<namespace>.svc.cluster.local`. The short form also works within the same cluster:

```sh
# Full form
curl http://nginx-service.nginx-demo.svc.cluster.local

# Short form (works anywhere in the cluster)
curl http://nginx-service.nginx-demo
```

### One-shot curl without entering a shell

```bash
kubectl exec curlutils -- curl -s http://nginx-service.nginx-demo
```

### Run the pod in a specific namespace

To test network policies that restrict cross-namespace traffic, add `namespace` to the manifest:

```yaml
metadata:
  name: curlutils
  namespace: nginx-demo   # add this line
```

Then apply as normal.

---

## Manifest Reference

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: curlutils
spec:
  containers:
  - name: curlutils
    image: curlimages/curl:8.12.1
    command: ['sh', '-c', 'echo "Hello, Kubernetes!" && sleep 3600']
    # sleep 3600 keeps the pod alive for 1 hour so you can exec into it
```
