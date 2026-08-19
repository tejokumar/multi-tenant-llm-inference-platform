# ADR 0003: Run the first cluster in us-central1

- **Status:** Superseded by [ADR 0005](0005-move-the-first-worker-to-us-east1.md)
- **Date:** 2026-08-19

## Context

The first workload needs one NVIDIA L4. Region changes affect compute price, GPU availability, network latency, and the chance that Autopilot can find capacity.

## Alternatives

We compared `us-central1`, `us-east1`, `us-west1`, and `us-west4`. The first three share the lowest listed G2 prices. `us-west4` costs more. `us-west1` is closer to the author, but proximity is not important for a controlled milestone that uses port forwarding.

## Comparison criteria

- current on-demand price
- number of zones that expose G2 machines
- available project quota
- relevance of network latency to the experiment

## Decision

Use `us-central1`. It shares the lowest price with `us-east1` and `us-west1`, exposes G2 machines in three zones, and the project has quota for one L4 there.

## Cost estimate

Google Cloud Billing Catalog prices on 2026-08-19 give this hourly estimate for `g2-standard-4`:

| Component | Calculation | Estimated cost per hour |
| --- | ---: | ---: |
| NVIDIA L4 | 1 × $0.560040239 | $0.560040239 |
| G2 CPU | 4 × $0.024988212 | $0.099952848 |
| G2 memory | 16 GiB × $0.002927448 | $0.046839168 |
| Autopilot L4 premium | 1 × $0.067 | $0.067000000 |
| Autopilot CPU premium | 4 × $0.003 | $0.012000000 |
| Autopilot memory premium | 16 GiB × $0.00035 | $0.005600000 |
| **Estimated total** | | **$0.791432255** |

This estimate excludes storage, network traffic, taxes, and price changes. It is not a bill or a spending cap.

## Consequences

- Autopilot can try three zones when it places the L4 workload.
- Requests from the author's location might have slightly higher network latency than `us-west1`.
- Moving later will require a new cluster and new measurements.

## Evidence

The Google Cloud project reports a regional quota limit of one on-demand L4 and one Spot L4 in `us-central1`. Google lists G2 support in `us-central1-a`, `us-central1-b`, and `us-central1-c`.

During the experiment, GKE returned `GCE out of resources` for `g2-standard-4` in all three zones. The price and quota comparison was correct, but current hardware capacity made this decision unusable.

## Limits

Quota and listed availability do not guarantee that a GPU will be available when the Pod is scheduled. Prices and capacity can change.

## Revisit when

Revisit the region if the Pod remains unscheduled because of capacity, data residency becomes important, users need lower latency elsewhere, or another supported region becomes materially cheaper.
