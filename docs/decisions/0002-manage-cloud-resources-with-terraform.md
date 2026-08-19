# ADR 0002: Manage cloud resources with Terraform

- **Status:** Accepted
- **Date:** 2026-08-19

## Context

The platform needs a repeatable Google Cloud environment. A sequence of commands can create the first cluster, but commands alone do not show the complete desired state or make later changes easy to review.

## Alternatives

### Google Cloud console

The console is useful for discovery. It is difficult to reproduce exactly, and a reader cannot review the final state as one artifact.

### `gcloud` scripts

Scripts are direct and easy to trace. They require us to write our own checks for existing resources, updates, dependencies, and cleanup.

### Terraform

Terraform describes the desired resources, shows a plan before changing them, tracks dependencies, and can destroy the lab when the experiment ends. It adds a state file and another tool to learn.

### OpenTofu

OpenTofu provides a similar workflow with an open-source license. Terraform has the more direct path in the current GKE documentation and is sufficient for this single-author lab.

## Comparison criteria

- reproducibility
- review before cloud changes
- cleanup safety
- value to the reader
- setup and maintenance cost

## Decision

Use Terraform for Google Cloud resources. Use Kubernetes manifests for objects inside the cluster. Keep Terraform state local during milestone 1 and exclude it from Git. Revisit remote state before CI or a second operator applies infrastructure.

## Consequences

- Cloud changes can be reviewed with `terraform plan`.
- Cleanup is explicit through `terraform destroy`.
- Losing the local state would make cleanup and future changes harder.
- CI must not apply infrastructure while state remains local.

## Evidence

Google documents Terraform as a supported way to create GKE Autopilot clusters. The installed CLI is Terraform 1.15.8.

## Limits

This decision does not select a long-term state backend or CI deployment model.

## Revisit when

Use remote state when another operator or automation needs to apply changes. Reconsider OpenTofu if licensing, governance, or tool compatibility becomes important.
