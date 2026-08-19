# ADR 0006: Disable Kubernetes Service links for vLLM

- **Status:** Accepted
- **Date:** 2026-08-19

## Context

Kubernetes injected `VLLM_PORT=tcp://...:8000` into the container because the Service is named `vllm`. vLLM uses the same variable as a numeric local port. Its engine exited before loading the model.

## Alternatives

- Rename the Service. This avoids the current collision but another Service name could collide later.
- Set `VLLM_PORT` explicitly. This fixes one variable while leaving other legacy Service variables in the container.
- Set `enableServiceLinks: false` on the Pod. Kubernetes DNS still resolves Services, and the legacy variables are not injected.

## Comparison criteria

- reliable startup
- effect on normal Kubernetes service discovery
- number of special cases
- clarity for future workers

## Decision

Set `enableServiceLinks: false` on the vLLM Pod. Use Kubernetes DNS for service discovery.

## Consequences

- vLLM controls its own `VLLM_*` environment variables.
- Applications cannot depend on automatically injected Service variables.
- Service DNS names continue to work.

## Evidence

Before the change, vLLM exited with `VLLM_PORT ... appears to be a URI`. After the change, the injected variable disappeared, the engine initialized, and `/health` returned HTTP 200.

## Limits

This prevents environment-variable collisions. It does not configure network policy, DNS reliability, or application authentication.

## Revisit when

Revisit only if a workload has a documented need for legacy Kubernetes Service variables.
