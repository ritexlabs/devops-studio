# Terraform Sample Stacks

This folder contains Terraform sample stacks that demonstrate practical infrastructure patterns for Kubernetes, application hosting, and observability.

## Purpose

The goal of these samples is to provide reproducible infrastructure starting points that help you learn how to provision core AWS resources with Terraform and quickly deploy supporting services.

## Available Stacks

### aws-playground-infra
Builds a foundational AWS playground by provisioning a VPC and an Application Load Balancer. Use this stack when you want a reusable network and load-balancing layer for quickly hosting EC2-based workloads behind a public endpoint.

### ec2-grafana-instance
Provision an EC2 instance in the playground VPC, install Grafana, and expose it through a load balancer and DNS name. Use this stack when you want a ready-to-use observability host for dashboards and monitoring demos.

### ec2-KinD-cluster
Provision an EC2 instance and deploy a KinD cluster on it. Use this stack when you want a fast, isolated Kubernetes environment for learning, testing, and validating deployments without relying on a managed cluster.

## Usage

1. Open the stack you want to use.
2. Review the stack README and variables file.
3. Update the local `terraform.tfvars` file with your environment-specific values.
4. Run `terraform init`, `terraform plan`, and `terraform apply`.
5. Remove any temporary infrastructure after validation.

## Notes

- Keep sensitive values out of Git.
- Use placeholder values in the repository where possible.
- Keep generated Terraform state and local-only files untracked.