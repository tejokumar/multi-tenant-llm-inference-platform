# Infrastructure

Infrastructure configuration is grouped by the tool that applies it:

- `terraform/` creates and configures Google Cloud resources.
- `kubernetes/` describes workloads and policies inside GKE Autopilot.

Do not commit credentials, Terraform state, or account-specific variable files.
