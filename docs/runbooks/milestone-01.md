# Runbook: Serve one request and remove the lab

This runbook creates the milestone 1 environment, serves one private request, runs the missing-GPU check, and removes the environment.

## Prerequisites

- Google Cloud project `tejo-llm-inference-lab` with billing enabled
- global GPU quota of at least one
- regional on-demand L4 quota of at least one in `us-east1`
- `gcloud`, Terraform 1.10 or newer, `kubectl`, and the GKE auth plugin

Quota does not reserve a GPU. If GKE reports `GCE out of resources`, stop and review ADR 0005 before changing the machine or zone.

## Create the cluster

```bash
cd infrastructure/terraform
terraform init
terraform fmt -check
terraform validate
GOOGLE_OAUTH_ACCESS_TOKEN="$(gcloud auth print-access-token)" terraform plan
GOOGLE_OAUTH_ACCESS_TOKEN="$(gcloud auth print-access-token)" terraform apply
gcloud container clusters get-credentials llm-inference-lab \
  --region us-east1 \
  --project tejo-llm-inference-lab
cd ../..
```

Read the plan before applying it. The plan creates a VPC, subnet, node service account, IAM binding, and Autopilot cluster. It does not create a GPU node.

## Deploy the worker

```bash
kubectl apply -f infrastructure/kubernetes/base/compute-class.yaml
kubectl apply -k infrastructure/kubernetes/base
kubectl wait -n inference-system \
  --for=condition=Ready \
  pod -l app.kubernetes.io/name=vllm \
  --timeout=30m
```

The ComputeClass must exist before GKE admission checks the Deployment. Use these commands while waiting:

```bash
kubectl get events -n inference-system --sort-by=.lastTimestamp
kubectl logs -n inference-system deployment/vllm-qwen3 --follow
kubectl get nodes \
  -L cloud.google.com/gke-accelerator,node.kubernetes.io/instance-type,topology.kubernetes.io/zone
```

## Send a request

In one terminal:

```bash
kubectl port-forward -n inference-system service/vllm 8000:8000
```

In another terminal:

```bash
curl --silent --show-error \
  -H 'Content-Type: application/json' \
  -d '{"model":"qwen3-1.7b","messages":[{"role":"user","content":"In one short sentence, explain what multi-tenancy means in an inference platform."}],"temperature":0,"max_tokens":64,"chat_template_kwargs":{"enable_thinking":false}}' \
  http://127.0.0.1:8000/v1/chat/completions | jq
```

Expect HTTP 200 and one completed assistant message.

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

Expect `cuda_available=False` and exit code 1.

## Cleanup

Stop the port-forward. Remove the Kubernetes objects, then destroy the cloud resources:

```bash
kubectl delete -k infrastructure/kubernetes/base
kubectl delete -f infrastructure/kubernetes/base/compute-class.yaml
cd infrastructure/terraform
GOOGLE_OAUTH_ACCESS_TOKEN="$(gcloud auth print-access-token)" terraform plan -destroy
GOOGLE_OAUTH_ACCESS_TOKEN="$(gcloud auth print-access-token)" terraform destroy
```

Verify the result:

```bash
gcloud container clusters list --project=tejo-llm-inference-lab
gcloud compute instances list --project=tejo-llm-inference-lab
terraform state list
```

All three commands should show no lab resources. Deleting only the port-forward does not stop GPU charges.
