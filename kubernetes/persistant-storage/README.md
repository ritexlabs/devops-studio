# Kubernetes Persistent Storage

By default, data written inside a container disappears when the pod restarts. **PersistentVolumes (PV)** and **PersistentVolumeClaims (PVC)** give pods durable storage that outlives pod restarts and rescheduling.

---

## Concepts

```
StorageClass     ← defines HOW storage is provisioned (hostPath, AWS EBS, GCP PD, …)
     │
     ▼
PersistentVolume (PV)     ← the actual storage resource (1 Gi, 20 Gi, …)
     │
     ▼
PersistentVolumeClaim (PVC)   ← a pod's request to use some of that storage
     │
     ▼
Pod   ← mounts the PVC at a path inside the container filesystem
```

| Object | Who creates it | Analogy |
|--------|---------------|---------|
| `StorageClass` | Admin | Catalogue of available disk types |
| `PersistentVolume` | Admin (static) or automatically (dynamic) | A physical disk |
| `PersistentVolumeClaim` | Developer / app manifest | Booking that disk |

---

## Files in This Directory

| File | What It Demonstrates |
|------|---------------------|
| `a1-create-pv.yaml` | Static PV — 1 Gi `hostPath`, `storageClassName: standard` |
| `a2-create-pvc.yaml` | PVC claiming the static PV above |
| `a3-create-pod.yaml` | nginx pod that mounts the PVC at `/data` |
| `allinone-aws-gp2.yaml` | PV + PVC + Pod in one file, using AWS `gp2` storage class |
| `dynamic-pv-creation.yaml` | AWS EBS StorageClass + StatefulSet with auto-provisioned PVCs |

---

## Path A — Static Provisioning (Local / KinD)

Apply manifests one step at a time to see what each resource does. These use a `hostPath` volume and work on any local cluster including KinD.

### Step 1 — Check your storage classes

```bash
kubectl get storageclass
```

Expected output on KinD:

```
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      AGE
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   5m
```

> The manifests use `storageClassName: standard`. If your cluster uses a different name, edit the YAML files to match.

### Step 2 — Create the PersistentVolume

```bash
kubectl apply -f a1-create-pv.yaml
kubectl get pv
```

```
NAME      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      STORAGECLASS   AGE
demo-pv   1Gi        RWO            Retain           Available   standard       10s
```

`Available` means no PVC has claimed it yet.

### Step 3 — Create the PersistentVolumeClaim

```bash
kubectl apply -f a2-create-pvc.yaml
kubectl get pvc
kubectl get pv
```

```
NAME          STATUS   VOLUME    CAPACITY   STORAGECLASS   AGE
pvc-dynamic   Bound    demo-pv   1Gi        standard       5s
```

The PV status changes from `Available` to `Bound`.

### Step 4 — Mount the PVC in a Pod

```bash
kubectl apply -f a3-create-pod.yaml
kubectl get pod pvc-pod
```

Wait for `Running`, then write a file to prove the volume works:

```bash
kubectl exec -it pvc-pod -- bash

# Inside the pod
ls /data                          # empty at first
echo "hello persistent" > /data/test.txt
cat /data/test.txt                # hello persistent
exit
```

Delete and recreate the pod — the file survives:

```bash
kubectl delete pod pvc-pod
kubectl apply -f a3-create-pod.yaml
kubectl exec -it pvc-pod -- cat /data/test.txt    # still there
```

### Clean up

```bash
kubectl delete -f a3-create-pod.yaml
kubectl delete -f a2-create-pvc.yaml
kubectl delete -f a1-create-pv.yaml
```

---

## Path B — All-in-One AWS gp2 (`allinone-aws-gp2.yaml`)

Combines PV, PVC, and Pod into a single manifest using the `gp2` storage class. Use this on EKS.

```bash
kubectl apply -f allinone-aws-gp2.yaml
kubectl get pv,pvc,pod
```

> On newer EKS clusters, the `gp2` class may not exist by default. Use `gp3` instead by editing `storageClassName: gp2` → `storageClassName: gp3`.

---

## Path C — Dynamic Provisioning with StatefulSet (`dynamic-pv-creation.yaml`)

The production pattern: a `StorageClass` backed by the AWS EBS CSI driver, and a `StatefulSet` that auto-creates a PVC per replica using `volumeClaimTemplates`.

**Prerequisites:** EKS cluster with the [EBS CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) add-on enabled.

```bash
kubectl apply -f dynamic-pv-creation.yaml
kubectl get storageclass,statefulset,pvc,pv
```

Kubernetes automatically provisions one EBS volume per StatefulSet replica.

To make the EBS class the cluster default:

```bash
kubectl patch storageclass ebs-sc \
  -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

---

## Best Practices

- **Prefer dynamic provisioning.** Static PVs require manual matching of PV and PVC properties and are hard to scale.
- **Always set `storageClassName` explicitly.** Omitting it falls back to the cluster default, which can change unexpectedly.
- **Use `Retain` reclaim policy for important data.** The `Delete` policy removes the underlying disk when the PVC is deleted — convenient but dangerous for production data.
- **Size storage generously upfront.** Not all storage drivers support live resize; check before relying on it.
- **Protect PVCs with RBAC.** Accidental deletion of a PVC with `Delete` reclaim policy causes irreversible data loss.
