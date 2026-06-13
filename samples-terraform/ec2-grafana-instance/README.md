# EC2 Grafana Instance

This stack provisions an EC2 instance in the playground VPC, installs Grafana, and exposes it through an Application Load Balancer and DNS name.

## Goal

Provide a ready-to-use observability host that can be deployed quickly for Grafana demos, dashboard exploration, and monitoring experiments.

## What It Builds

- An EC2 instance in the shared playground network
- Grafana installed and configured on the instance
- Load balancer and DNS-based access for the Grafana endpoint

## Usage

1. Update `terraform.tfvars` with your environment-specific values.
2. Run `terraform init`.
3. Run `terraform plan`.
4. Run `terraform apply --auto-approve`.
5. Open the Grafana endpoint through the configured load balancer and DNS name.

## Optional Logging Setup

You can add Loki and Promtail if you want to collect and visualize logs alongside Grafana.