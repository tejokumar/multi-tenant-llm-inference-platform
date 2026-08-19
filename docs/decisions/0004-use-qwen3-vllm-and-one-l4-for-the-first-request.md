# ADR 0004: Use Qwen3, vLLM, and one L4 for the first request

- **Status:** Accepted
- **Date:** 2026-08-19

## Context

Milestone 1 needs a real language model, a serving runtime, and a GPU. The combination must be inexpensive enough for repeated experiments and still use the same request path we can extend in later milestones.

## Alternatives

### Model

- Qwen3-0.6B would start faster but leaves much of an L4 unused and feels closer to a smoke-test model.
- Qwen3-1.7B is small, Apache 2.0 licensed, chat capable, and has enough memory headroom for a clear first experiment.
- An 8B model would be more representative, but BF16 weights and KV cache would make the 24 GB memory boundary more important before we have basic measurements.

### Runtime

- Hugging Face Transformers is the shortest Python path, but we would need to build the HTTP and streaming layer ourselves.
- NVIDIA Triton is a broad inference server, but it adds model packaging and configuration that do not help the first LLM request.
- vLLM includes an OpenAI-compatible streaming API and leads directly to later work on batching, KV cache use, and scheduling.

### GPU

- T4 is older and cheaper in some configurations, with 16 GB of memory and weaker support for modern low-precision execution.
- L4 is designed for inference, has 24 GB of memory, and is available in the selected region.
- A100 and H100 provide more memory and throughput than this milestone needs at a much higher hourly price.

### Access

- A public LoadBalancer would be convenient but would add public exposure, authentication, and network cost.
- Ingress would add another routing layer before it is needed.
- `kubectl port-forward` keeps the Service private and exposes only a temporary local connection.

## Comparison criteria

- ability to serve a real chat request
- GPU memory headroom
- cost
- license and access restrictions
- fit with later milestones
- number of unrelated components introduced now

## Decision

Serve `Qwen/Qwen3-1.7B` with the official vLLM 0.26.0 OpenAI container on one NVIDIA L4. Limit the first experiment to 8,192 context tokens and access it through `kubectl port-forward`.

Pin the container to the published multi-platform image digest:

```text
sha256:ffb2d59b1c059a5bd8d781320c9f5189de8293693b7d95da54befddaa54abf52
```

## Consequences

- The API shape can remain stable when tenants and multiple workers are added.
- The model leaves ample GPU memory for observing the runtime and KV cache.
- The first measurement will not represent the behavior of an 8B or larger model.
- The official image is large, so image pull time will be visible in cold-start evidence.
- No endpoint is reachable without current Kubernetes credentials and an active port-forward process.

## Evidence

The Qwen model card reports 1.7 billion parameters, a 32,768-token context window, and an Apache 2.0 license. vLLM documents Qwen support, streaming, and its OpenAI-compatible server. The selected model repository is approximately 4.08 GB, which fits well within an L4's 24 GB of GPU memory.

## Limits

Fit does not prove good throughput, latency, output quality, or cost efficiency. Those require measurements. The 8,192-token experiment does not validate the model's full context window.

## Revisit when

Revisit the model and GPU after we measure one worker, or sooner if the selected image cannot start on the GKE-provided driver.
