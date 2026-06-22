# Kubernetes Utilities

Helper manifests for debugging and troubleshooting inside a Kubernetes cluster. These are not application deployments — they are on-demand tools you launch when you need to investigate something.

---

## Files in This Directory

| File | What It Does |
|------|-------------|
| `launch-curlutils-pod.yaml` | Launches a pod with the `curl` command available |

---

## curl Utility Pod

### What It Is

`launch-curlutils-pod.yaml` starts a pod using the `curlimages/curl:8.12.1` image. The pod runs `sleep 3600` (1 hour) to stay alive, giving you a shell to run `curl` commands against any endpoint inside the cluster.

This is useful because:

- Pods inside the cluster have access to **private cluster IP addresses** and **service DNS names** that are not reachable from your laptop.
- `curl` lets you test HTTP connectivity between services, check health endpoints, and verify that DNS resolution is working — all from within the cluster network.

### When to Use It

- Testing whether a service is reachable from inside the cluster (`curl http://my-service.my-namespace/health`)
- Verifying internal DNS (`curl http://nginx-service.nginx-demo`)
- Checking an endpoint that is not exposed outside the cluster (ClusterIP services)
- Diagnosing network policy or RBAC issues

---

## Step 1 — Launch the Pod

```bash
kubectl apply -f launch-curlutils-pod.yaml
```

Wait for the pod to be ready:

```bash
kubectl get pod curlutils --watch
# Wait until STATUS shows "Running"
```

---

## Step 2 — Open a Shell Inside the Pod

```bash
kubectl exec -it curlutils -- sh
```

You are now inside the cluster network. Run any `curl` command:

```sh
# Test a service by its DNS name (format: <service>.<namespace>)
curl http://nginx-service.nginx-demo

# Test a service by cluster IP
curl http://10.96.12.34

# Check an HTTP health endpoint
curl -v http://my-app-service.my-namespace/health

# Follow redirects and show headers
curl -Lv http://my-service.default

# Test HTTPS (with -k to skip cert verification for internal certs)
curl -k https://my-secure-service.default

# Exit the shell when done
exit
```

---

## Step 3 — Remove the Pod When Done

The pod stays alive for 1 hour (3600 seconds). Remove it manually when finished:

```bash
kubectl delete -f launch-curlutils-pod.yaml
# or
kubectl delete pod curlutils
```

---

## Tips

### Reach services in any namespace

Kubernetes internal DNS follows the pattern `<service-name>.<namespace>.svc.cluster.local`. The short form `<service-name>.<namespace>` also works:

```sh
# Full DNS name
curl http://nginx-service.nginx-demo.svc.cluster.local

# Short form (works within the same cluster)
curl http://nginx-service.nginx-demo
```

### Check DNS resolution

```sh
# Look up a service's cluster IP
nslookup nginx-service.nginx-demo
```

### Run a one-shot curl without entering a shell

```bash
kubectl exec curlutils -- curl -s http://nginx-service.nginx-demo
```

### Launch in a specific namespace

If you need the pod to run inside a particular namespace (e.g., to test network policies that restrict cross-namespace traffic), edit the manifest to add a `namespace` field:

```yaml
metadata:
  name: curlutils
  namespace: nginx-demo   # add this line
```

Then apply as usual.

---

## Manifest Reference

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: curlutils           # pod name — used in kubectl exec
spec:
  containers:
  - name: curlutils
    image: curlimages/curl:8.12.1
    command: ['sh', '-c', 'echo "Hello, Kubernetes!" && sleep 3600']
    # sleep 3600 keeps the pod alive for 1 hour so you can exec into it
```
