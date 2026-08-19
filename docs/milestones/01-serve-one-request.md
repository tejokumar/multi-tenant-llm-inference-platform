# Milestone 1: Serve one request

## Question

What happens between applying a model-serving workload to Kubernetes and receiving the first generated token?

## What we need to learn

1. How model weights, runtime memory, and the KV cache use GPU memory.
2. How prefill processes input tokens and decode produces output tokens.
3. How Kubernetes gives a container access to a GPU.
4. How GKE Autopilot creates a GPU node for a pending Pod.
5. How vLLM exposes a model through an OpenAI-compatible API.
6. Which parts of startup time come from node creation, image pulling, model downloading, and model loading.

## Selected path

- Google Cloud project: `tejo-llm-inference-lab`
- Region: `us-east1`
- Cluster: GKE Autopilot on the Regular release channel
- Machine: `g2-standard-8`
- Zone: `us-east1-c`
- GPU: one NVIDIA L4 with 24 GB of GPU memory
- Model: `Qwen/Qwen3-1.7B`
- Runtime: `vllm/vllm-openai:v0.26.0`
- Access: a private Kubernetes Service reached with `kubectl port-forward`
- Model context limit for this experiment: 8,192 tokens

The model supports a longer context. We start at 8,192 tokens to leave a simple and predictable memory boundary while learning the request path.

## Build sequence

1. Create the Autopilot cluster with Terraform.
2. Connect `kubectl` to the cluster.
3. Apply the `l4-medium-us-east1-c` ComputeClass before the workload that selects it.
4. Deploy vLLM and wait for Autopilot to create the GPU node.
5. Record scheduling, image pull, model download, and readiness events.
6. Forward local port 8000 to the private Service.
7. Send one normal request and one streaming request.
8. Record time to first token and total response time.
9. Run the missing-GPU failure exercise.
10. Remove the workload, verify that the GPU node is removed, and destroy the cluster.

## Evidence to keep

- Terraform plan and applied resource summary
- Pod events with timestamps
- selected vLLM startup logs
- node labels and installed NVIDIA driver version
- request and response samples
- time to first token and total request time
- GPU memory after model loading
- the missing-GPU failure and explanation
- final cleanup output

Sanitize project numbers, access tokens, private addresses, and other credentials before committing evidence.

## Completion test

Another engineer can follow the repository, create the cluster, serve one request, reproduce the missing-GPU failure, inspect the evidence, and remove every billable resource.

This milestone does not test concurrency, batching, fairness, autoscaling signals, public ingress, or production availability.

## Result

Completed on 2026-08-19. The worker served normal and streaming requests, the missing-GPU check failed as expected, and Terraform removed all lab resources. See the [result](../../evidence/milestone-01/result.md).
