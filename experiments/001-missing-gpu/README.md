# Experiment 001: Start vLLM without a GPU request

## Question

What does Kubernetes give a container when its Pod does not request `nvidia.com/gpu`?

## Expected result

The Pod runs on a normal node. vLLM cannot find a CUDA device and exits before it serves requests.

## Why run this failure

A node selector chooses where a Pod may run. A resource limit allocates the GPU device to the container. Seeing the failure makes that distinction concrete.

## Procedure

Apply `pod.yaml` after the successful worker is healthy:

```bash
kubectl apply -f experiments/001-missing-gpu/pod.yaml
kubectl wait -n inference-system \
  --for=jsonpath='{.status.phase}'=Failed \
  pod/missing-gpu-check \
  --timeout=5m
kubectl logs -n inference-system missing-gpu-check
kubectl delete -f experiments/001-missing-gpu/pod.yaml
```

The Pod uses the same pinned vLLM image but runs a small CUDA visibility check. It deliberately omits the ComputeClass selector and `nvidia.com/gpu` limit.

## Observed result

GKE scheduled the Pod on an `ek-standard-8` node with no accelerator label. It exited with code 1:

```text
cuda_available=False
AssertionError: CUDA device is not visible; request nvidia.com/gpu
```

This proves that a CUDA-enabled image does not grant access to a GPU. Kubernetes exposes the device only when the Pod requests `nvidia.com/gpu`.

## Limits

This failure shows that the container lacks a GPU. It does not test GPU driver failures, insufficient GPU memory, or regional capacity errors.
