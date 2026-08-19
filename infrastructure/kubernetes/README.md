# Kubernetes

The `base/` directory contains milestone 1:

- an `inference-system` namespace
- a custom ComputeClass for the verified `g2-standard-8` L4 shape in `us-east1-c`
- one vLLM Deployment serving Qwen3-1.7B
- a private ClusterIP Service

## Deploy

Connect `kubectl` to the lab cluster, then run:

```bash
kubectl apply -f infrastructure/kubernetes/base/compute-class.yaml
kubectl apply -k infrastructure/kubernetes/base
kubectl get pods -n inference-system --watch
```

Create the ComputeClass first. Kubernetes sorts built-in workload objects before unknown custom resources during a combined apply, but GKE admission requires the named ComputeClass to exist before it accepts the Deployment.

The first start includes GPU node creation, a large image pull, model download, and model loading. Inspect the timestamps rather than treating the wait as one number:

```bash
kubectl describe pod -n inference-system -l app.kubernetes.io/name=vllm
kubectl logs -n inference-system deployment/vllm-qwen3 --follow
```

If GKE reports `GCE out of resources`, the zone has no capacity for that machine shape. Quota does not reserve hardware. See ADR 0005 before changing the zone or machine type.

## Send a private request

```bash
kubectl port-forward -n inference-system service/vllm 8000:8000
curl http://127.0.0.1:8000/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"model":"qwen3-1.7b","messages":[{"role":"user","content":"Explain what a Kubernetes Pod is in two sentences."}],"max_tokens":80,"stream":false,"chat_template_kwargs":{"enable_thinking":false}}'
```

Qwen3 enables a reasoning mode by default. `enable_thinking:false` asks for a direct answer, which makes this smoke test short and predictable.

## Run the missing-GPU check

```bash
kubectl apply -f experiments/001-missing-gpu/pod.yaml
kubectl wait -n inference-system \
  --for=jsonpath='{.status.phase}'=Failed \
  pod/missing-gpu-check \
  --timeout=5m
kubectl logs -n inference-system missing-gpu-check
kubectl delete -f experiments/001-missing-gpu/pod.yaml
```

The expected output includes `cuda_available=False`. The Pod must run on a normal node with no accelerator label.

## Stop GPU charges

```bash
kubectl delete -k infrastructure/kubernetes/base
kubectl delete -f infrastructure/kubernetes/base/compute-class.yaml
kubectl get nodes --watch
```

Wait until the GPU node disappears, or destroy the cluster with Terraform. Deleting only the local port-forward does not stop the GPU.
