# ADR 0005: Move the first worker to us-east1

- **Status:** Accepted
- **Date:** 2026-08-19
- **Supersedes:** [ADR 0003](0003-run-the-first-cluster-in-us-central1.md)

## Context

The project had quota for one L4 in `us-central1`, but GKE could not create `g2-standard-4` in `us-central1-a`, `-b`, or `-c`. Each attempt returned `GCE out of resources`. Quota permits an allocation; it does not reserve hardware.

## Alternatives

- Wait and retry `us-central1`. This keeps the lowest-cost shape but gives no completion time.
- Move to `us-west1`. It has the same listed price, but we had not tested its current capacity.
- Move to `us-east1`. It has the same listed price and quota for one L4.
- Use a larger G2 shape. This costs more but can use a different capacity pool.
- Use Spot capacity. It costs less but can be interrupted and is a poor default for the first deterministic request.

## Comparison criteria

- ability to allocate one L4 now
- hourly price
- repeatability
- time spent waiting in autoscaler backoff
- value of the result for later milestones

## Decision

Move the cluster to `us-east1`. Try `g2-standard-4` first, then use `g2-standard-8` in `us-east1-c` after the smaller shape also reports no capacity.

The verified worker is estimated at $0.955824271 per hour before storage, network traffic, taxes, and price changes. The extra cost is CPU and memory; both shapes use one L4.

## Consequences

- The first milestone can run on hardware that was available during the test.
- The worker costs about $0.16 more per hour than the original estimate.
- The manifest is tied to `us-east1-c` and must be reviewed if capacity changes.
- A production design should offer fallback shapes and regions instead of relying on one zone.

## Evidence

`g2-standard-4` failed for capacity in all three tested `us-central1` zones and in `us-east1-b` and `us-east1-c`. `g2-standard-8` created an NVIDIA L4 node in `us-east1-c`. GKE reported driver `580.159.04` and 23,034 MiB of GPU memory.

## Limits

This is a point-in-time capacity result, not proof that `us-east1-c` will always be available. It does not compare sustained latency between regions.

## Revisit when

Recheck `g2-standard-4` before longer benchmarks. Add a fallback policy when worker availability becomes part of the platform contract.
