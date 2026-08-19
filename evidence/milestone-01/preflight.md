# Milestone 1 preflight

- **Checked:** 2026-08-19
- **Google Cloud project:** `tejo-llm-inference-lab`
- **Billing:** enabled
- **Initially selected region:** `us-central1`
- **Verified region:** `us-east1`
- **Compute Engine API:** enabled
- **Kubernetes Engine API:** enabled
- **On-demand L4 quota:** limit 1, usage 0
- **Spot L4 quota:** limit 1, usage 0
- **Initial visible G2 zones:** `us-central1-a`, `us-central1-b`, `us-central1-c`
- **Verified zone:** `us-east1-c`
- **Global GPU quota:** initially 0, increased to 1 before deployment
- **Regional on-demand L4 quota:** limit 1 in `us-central1`, `us-east1`, and `us-west1`
- **Final cleanup:** 0 clusters, 0 VM instances, 0 lab networks, 0 Terraform resources

The Google Cloud Billing Catalog query produced an estimated `g2-standard-4` total of $0.791432255 per running hour. That shape had no capacity in all three tested `us-central1` zones and two tested `us-east1` zones. The verified `g2-standard-8` worker is estimated at $0.955824271 per hour before storage and network charges.

Quota and visible zones do not guarantee that capacity will be available when the workload starts.
