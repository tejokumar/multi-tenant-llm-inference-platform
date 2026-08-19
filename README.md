# Multi-Tenant LLM Inference Platform

This project asks one question: How can several tenants share GPU workers without one workload making the platform slow or unreliable for everyone else?

We will answer it by building and testing a real platform on Google Kubernetes Engine (GKE) Autopilot. Each milestone must produce working software, a repeatable experiment, and evidence that explains what happened.

The learning narrative is published on [tejo.dev](https://tejo.dev/projects/multi-tenant-llm-inference-platform/). This repository is the source of truth for code, infrastructure, decision records, experiments, evidence, and runbooks.

## Current milestone

**2. Measure one worker — next**

Milestone 1 is complete. We ran one model on one GPU worker, sent normal and streaming requests, reproduced a missing-GPU failure, and removed every lab resource.

The verified deployment uses Qwen3-1.7B, vLLM 0.26.0, one NVIDIA L4 on `g2-standard-8`, and `us-east1-c`. See the [milestone result](evidence/milestone-01/result.md) and [runbook](docs/runbooks/milestone-01.md).

## Functional milestones

1. Serve one request.
2. Measure one worker.
3. Create overload.
4. Add tenants.
5. Add multiple workers.
6. Add autoscaling.
7. Make the platform operable.
8. Explain the complete system.

Progress is based on completed functionality and verified learning outcomes. It is not based on dates or estimated time.

## Repository map

| Path | What belongs here |
| --- | --- |
| `platform/` | API, routing, scheduling, and worker code |
| `infrastructure/` | Terraform and Kubernetes configuration |
| `experiments/` | Repeatable workloads and failure exercises |
| `evidence/` | Sanitized measurements, traces, logs, and conclusions |
| `docs/decisions/` | Ordered architecture decision records (ADRs) |
| `docs/architecture/` | Architecture and request-flow documentation |
| `docs/runbooks/` | Deployment, recovery, and operating procedures |
| `examples/` | Small requests and configurations readers can run |
| `tests/` | Integration and load tests |

The directories contain short guidance now. Working artifacts will replace or extend that guidance as each milestone begins.

## Cost boundary

The verified GPU worker is estimated at about $0.96 for each hour it runs, before storage and network charges. The cheaper `g2-standard-4` shape was unavailable during the experiment. The Kubernetes Service is private. Always follow the cleanup step in the runbook when an experiment ends.

## Rules for an experiment

Every experiment must record:

- the question being tested
- the exact software and infrastructure versions
- the configuration and commands used
- the expected result
- the observed result
- a failure or difficult case when it matters
- what the evidence proves and what it does not prove

Do not commit credentials, tenant data, private endpoints, or unsanitized production logs.

## License

The project is licensed under the Apache License 2.0. See [LICENSE](LICENSE).
