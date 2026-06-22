# DevOps Studio

A practical learning repository for DevOps sample apps, demo apps, quick references, notes, and examples.

This repo is meant to help anyone learn DevOps faster by keeping common workflows, small experiments, and reusable examples in one place.

## What you will find here

- Sample applications for hands-on practice
- Demo apps that show specific DevOps patterns
- Quick references for common commands and tools
- Notes and examples for faster review and revision
- Small, focused experiments that explain one concept at a time

## Repository Structure

```text
.
├── kubernetes/
│   ├── KinD-cluster/              # Local multi-node Kubernetes cluster with KinD + Docker
│   ├── ingress/                   # Ingress manifests — Traefik, EKS ALB, GKE GCE
│   ├── persistant-storage/        # Persistent Volume and PVC examples
│   ├── sample-apps/
│   │   ├── nginx/                 # First Kubernetes app — Namespace, Deployment, Service, Ingress
│   │   ├── colorapp/              # Python/Flask color app — env vars, replicas, load balancing
│   │   ├── colorapp-ingress-dns/  # EKS ALB and GKE cloud ingress for colorapp
│   │   └── nginx-ingress-dns/     # Traefik TLS IngressRoute for nginx
│   └── utilities/                 # Debug tooling — curl pod for in-cluster connectivity testing
├── samples-python/
│   └── webapps/
│       └── colorapp/              # Python/Flask colorapp source
├── samples-nodejs/
│   ├── nodejs-web/
│   └── nodejs-static/
├── samples-terraform/
│   ├── ec2-KinD-cluster/          # Terraform stack: EC2 + KinD cluster
│   ├── ec2-grafana-instance/      # Terraform stack: EC2 Grafana instance
│   └── aws-playground-infra/      # Terraform stack: general AWS playground
└── README.md
```

If you add a new topic, keep it small and easy to scan. Prefer one concept per folder or file.

- Kubernetes manifests, cluster setup, and sample app deployments → [kubernetes/](kubernetes/)
- Python sample app source → [samples-python/webapps/colorapp](samples-python/webapps/colorapp)
- Node.js sample apps → [samples-nodejs/](samples-nodejs/)
- Terraform infrastructure stacks → [samples-terraform/](samples-terraform/)

## How to use this repo

1. Pick a topic you want to learn.
2. Open the matching app, note, or example.
3. Run or read only the part you need.
4. Revisit the quick reference when you need a reminder.
5. Add your own notes after you test something locally.

## Contributing content

When adding content, try to keep it:

- short and practical
- focused on one DevOps idea
- easy to run or easy to read
- named clearly so it is easy to search later

Useful additions include:

- deployment examples
- CI/CD snippets
- Docker and container notes
- Kubernetes examples
- cloud basics and reference commands
- monitoring, logging, and alerting notes
- incident response checklists

## Local development and secrets

Do not commit secrets, tokens, passwords, or API keys to the repository.

Use local environment files for real values and keep templates in version control when needed:

- `.env` for local-only secrets
- `.env.example` for placeholders and documentation

For Terraform samples, keep local variable values in `terraform.tfvars` only when required by the sample, and keep any sensitive cloud values out of Git. Use placeholder values in the repository and keep Terraform state and generated files out of version control.

## License

Add a license when you are ready to publish or share the repository broadly.
