variable "project_id" {
  description = "Google Cloud project that owns the lab."
  type        = string
  default     = "tejo-llm-inference-lab"
}

variable "region" {
  description = "Google Cloud region for the regional GKE Autopilot cluster."
  type        = string
  default     = "us-east1"

  validation {
    condition     = contains(["us-central1", "us-east1", "us-west1"], var.region)
    error_message = "Use a reviewed low-cost region: us-central1, us-east1, or us-west1."
  }
}

variable "cluster_name" {
  description = "Name of the GKE Autopilot cluster."
  type        = string
  default     = "llm-inference-lab"
}
