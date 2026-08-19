# Milestone 1 result: Serve one request

- **Run date:** 2026-08-19
- **Region and zone:** `us-east1-c`
- **Cluster:** GKE Autopilot `1.35.6-gke.1641000`, Regular channel
- **Worker:** `g2-standard-8`, one NVIDIA L4
- **Driver:** `580.159.04`
- **Runtime:** vLLM `0.26.0`
- **Model:** `Qwen/Qwen3-1.7B`
- **Context limit:** 8,192 tokens

## Outcome

The worker became healthy and served both normal and streaming OpenAI-compatible chat requests. The private Service was reached through `kubectl port-forward`. No public endpoint was created.

## What happened during startup

| Stage | Observed result |
| --- | --- |
| GPU capacity | `g2-standard-4` was unavailable in five tested zones across two regions. `g2-standard-8` succeeded in `us-east1-c`. |
| GPU node | GKE created an L4 node in about one minute. The device plugin then advertised one allocatable GPU. |
| Container image | 8,914,087,113 bytes; pulled in 3.213 seconds from the available registry path. |
| Model download | 3.78 GiB in 27.09 seconds. |
| Weight load | 2 shards in 2.41 seconds; 3.22 GiB of GPU memory for weights. |
| Torch compilation | 40.29 seconds. |
| CUDA graphs | 7 seconds and 0.45 GiB. |
| Fixed Pod to Ready | About 4 minutes, including Python imports, model setup, download, compilation, and warm-up. |

vLLM allocated 14.85 GiB to the KV cache. It reported room for 139,056 cached tokens and estimated 16.97 concurrent requests at the configured 8,192-token maximum. These are runtime estimates, not measured throughput.

## Request evidence

The first useful non-streaming request returned HTTP 200:

```text
first_byte_seconds=0.985264
total_seconds=0.985650
prompt_tokens=29
completion_tokens=40
```

Response:

```text
Multi-tenancy in an inference platform refers to a system where multiple users (tenants) share the same underlying infrastructure, allowing each tenant to have their own isolated environment while sharing resources efficiently.
```

A warm streaming request returned HTTP 200:

```text
stream_first_byte_seconds=0.333258
stream_total_seconds=1.273798
```

The stream ended with `data: [DONE]`.

## GPU evidence

After model loading, `nvidia-smi` reported:

```text
NVIDIA L4, driver 580.159.04, 23034 MiB total, 20124 MiB used
```

## Failures that taught us something

1. The project had regional L4 quota but a separate global GPU quota of zero. Increasing the global limit to one removed the quota error.
2. Quota did not guarantee capacity. GKE returned `GCE out of resources` for every tested `g2-standard-4` placement.
3. A Service named `vllm` injected a URI into `VLLM_PORT`. vLLM expects a number and exited. `enableServiceLinks: false` fixed the collision while keeping Service DNS.
4. A Pod that used the CUDA-enabled image without requesting `nvidia.com/gpu` ran on a normal node, reported `cuda_available=False`, and exited with code 1.

## Cleanup evidence

Terraform reported `0 added, 0 changed, 8 destroyed`. Read-only checks then reported:

```text
clusters=0
instances=0
lab_networks=0
terraform_resources=0
```

The Google Cloud project remains active. The lab cluster, nodes, network, subnet, IAM binding, and node service account were removed.

## Limits

- The timings come from one worker and a few requests. They are not a benchmark.
- `curl` first-byte time for a stream includes the first server-sent event. It is close to, but not a precise measurement of, the first generated token.
- Capacity and prices can change.
- The model cache used `emptyDir`, so replacing the Pod caused another model download.
- This milestone did not test multiple tenants, concurrent load, batching, fairness, autoscaling, public access, or failure recovery.
