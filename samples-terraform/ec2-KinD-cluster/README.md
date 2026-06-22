# EC2 KinD Cluster

This stack provisions an EC2 instance and installs a local KinD Kubernetes cluster on it. It is intended for fast, repeatable Kubernetes practice and application validation in an isolated environment.

## Goal

Provide a lightweight Kubernetes playground that lets you test manifests, rehearse deployments, and explore cluster behavior without depending on a managed Kubernetes service.

## What It Builds

- An EC2 instance sized for KinD
- A KinD-based Kubernetes cluster running on the instance
- Optional host-level access for exposed NodePorts and dashboard endpoints

## Usage

1. Update `terraform.tfvars` with your environment-specific values.
2. Run `terraform init`.
3. Run `terraform plan`.
4. Run `terraform apply --auto-approve`.
5. SSH into the EC2 instance and verify the cluster with `kubectl cluster-info`, `kubectl get nodes`, and `kubectl get pods -A`.

## External Access

Port range `32000-32010` is exposed on the EC2 host network. Port `32000` is reserved for the Kubernetes dashboard.

The dashboard is available at:

```text
https://<resource_prefix>-kind-dashboard.<domain_name>
```

Use the token stored on the EC2 instance at:

```text
/home/ubuntu/configs/admin-user-token
```

## Optional Demo Workload

You can deploy the sample voting application to validate the cluster and confirm external access paths.

The voting app Helm chart is available at:

```text
https://github.com/ritexlabs/chart-shelf/tree/main/votingapp
```

