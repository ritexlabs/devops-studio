# Kubernetes Persistent Storage

By default, data written inside a container is lost when the pod restarts. **Persistent Volumes (PV)** and **Persistent Volume Claims (PVC)** give pods stable storage that survives restarts and rescheduling.

---

## Key Concepts

```
StorageClass  ←  defines HOW storage is provisioned (cloud disk, host path, NFS, …)
     │
     ▼
PersistentVolume (PV)  ←  the actual storage resource (1 Gi, 20 Gi, …)
     │
     ▼
PersistentVolumeClaim (PVC)  ←  a pod's "request" for storage
     │
     ▼
Pod  ←  mounts the PVC at a path inside the container
```

| Object | Who Creates It | Analogy |
|--------|---------------|---------|
| `StorageClass` | Cluster admin | Storage catalogue |
| `PersistentVolume` | Admin (static) or auto (dynamic) | A physical disk |
| `PersistentVolumeClaim` | Developer / app | Booking that disk |

---

## Files in This Directory

| File | What It Demonstrates |
|------|---------------------|
| `a1-create-pv.yaml` | Static PV — 1 Gi hostPath, `storageClassName: standard` |
| `a2-create-pvc.yaml` | PVC that claims the static PV above |
| `a3-create-pod.yaml` | nginx pod that mounts the PVC at `/data` |
| `allinone-aws-gp2.yaml` | All-in-one PV + PVC + Pod using AWS gp2 storage class |
| `dynamic-pv-creation.yaml` | AWS EBS StorageClass + StatefulSet with auto-provisioned PVs |

---

## Path A — Static Provisioning (Local / KinD Cluster)

Apply the manifests one at a time to see each step. These use a `hostPath` volume and work on any local cluster including KinD.

### Step 1 — Check your cluster's available storage classes

```bash
kubectl get storageclass
```

Expected output on a KinD cluster:

```
NAME                 PROVISIONER                RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
standard (default)   rancher.io/local-path      Delete          WaitForFirstConsumer false                  5m
```

> The manifests in this directory use `storageClassName: standard`. If your cluster uses a different name, edit the YAML files accordingly.

### Step 2 — Create the Persistent Volume

```bash
kubectl apply -f a1-create-pv.yaml
kubectl get pv
```

Expected output:

```
NAME      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   AGE
demo-pv   1Gi        RWO            Retain           Available           standard       10s
```

`Available` means the PV exists but has not been claimed by any PVC yet.

### Step 3 — Create the Persistent Volume Claim

```bash
kubectl apply -f a2-create-pvc.yaml
kubectl get pvc
kubectl get pv
```

Expected output (PVC):

```
NAME          STATUS   VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-dynamic   Bound    demo-pv   1Gi        RWO            standard       5s
```

The PV status changes from `Available` to `Bound` because the PVC has claimed it.

### Step 4 — Mount the PVC in a Pod

```bash
kubectl apply -f a3-create-pod.yaml
kubectl get pod pvc-pod
```

Wait until the pod shows `Running`, then write a file to the mounted volume:

```bash
# Open a shell inside the running pod
kubectl exec -it pvc-pod -- bash

# Inside the pod — the /data directory is your persistent volume
ls /data                    # empty initially
echo "hello persistent" > /data/test.txt
cat /data/test.txt          # hello persistent
exit
```

Now delete and recreate the pod to prove the data persists:

```bash
kubectl delete pod pvc-pod
kubectl apply -f a3-create-pod.yaml
kubectl exec -it pvc-pod -- cat /data/test.txt   # still there!
```

### Clean up

```bash
kubectl delete -f a3-create-pod.yaml
kubectl delete -f a2-create-pvc.yaml
kubectl delete -f a1-create-pv.yaml
```

---

## Path B — All-in-One (AWS gp2)

`allinone-aws-gp2.yaml` combines the PV, PVC, and Pod into a single file using the `gp2` storage class. Use this on an EKS cluster that has the EBS CSI driver installed.

```bash
kubectl apply -f allinone-aws-gp2.yaml
kubectl get pv,pvc,pod
```

> **Note:** `gp2` is the legacy AWS EBS storage class. On newer EKS clusters, use `gp3` instead. Update `storageClassName: gp2` → `storageClassName: gp3` if needed.

---

## Path C — Dynamic Provisioning with StatefulSet (AWS EBS CSI)

`dynamic-pv-creation.yaml` shows the production-grade pattern: a `StorageClass` backed by the EBS CSI driver, and a `StatefulSet` that automatically creates a PVC per replica using `volumeClaimTemplates`.

**Prerequisites:**
- EKS cluster with the [EBS CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) installed.

**Steps:**

1. Apply the manifest:
   ```bash
   kubectl apply -f dynamic-pv-creation.yaml
   ```

2. Kubernetes automatically creates a PV for each replica:
   ```bash
   kubectl get pvc
   kubectl get pv
   kubectl get statefulset djangpostgresql
   ```

3. To set the EBS storage class as the cluster default:
   ```bash
   kubectl patch storageclass ebs-sc \
     -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
   ```

---

## Best Practices

- **Prefer dynamic provisioning** over static PVs. It scales better and reduces manual work.
- **Set a `storageClassName` explicitly** on every PVC. Relying on the default class can cause surprises if the default changes.
- **Use `Retain` reclaim policy** for important data. The `Delete` policy removes the underlying disk when the PVC is deleted, which is convenient but dangerous for production data.
- **Size generously.** Resizing a PV after creation is possible but depends on the storage driver — not all support it.
- **Protect with RBAC.** Accidental deletion of a PVC with `Delete` reclaim policy causes irreversible data loss.
