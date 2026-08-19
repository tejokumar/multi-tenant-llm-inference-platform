# Terraform

This configuration creates the private network and GKE Autopilot cluster for milestone 1. It does not deploy the GPU workload. The GPU node starts only after the Kubernetes Deployment is applied.

## Prerequisites

- Terraform 1.10 or newer
- Google Cloud CLI authenticated as an account that can manage the project
- Application Default Credentials, or a temporary `GOOGLE_OAUTH_ACCESS_TOKEN`

The current project and region defaults are safe for this lab:

```text
project_id = tejo-llm-inference-lab
region     = us-east1
```

## Review before creating resources

```bash
terraform init
terraform fmt -check
terraform validate
GOOGLE_OAUTH_ACCESS_TOKEN="$(gcloud auth print-access-token)" terraform plan
```

Read the plan. It should create a custom VPC, subnet, GKE node service account, IAM binding, and one Autopilot cluster. It should not create a GPU node.

## Create and connect

```bash
GOOGLE_OAUTH_ACCESS_TOKEN="$(gcloud auth print-access-token)" terraform apply
gcloud container clusters get-credentials llm-inference-lab \
  --region us-east1 \
  --project tejo-llm-inference-lab
```

## Cleanup

Remove the Kubernetes workload first and confirm that the GPU node is gone. Then run:

```bash
GOOGLE_OAUTH_ACCESS_TOKEN="$(gcloud auth print-access-token)" terraform destroy
```

Terraform state is local for this milestone and is excluded from Git. Do not run this configuration from CI.
