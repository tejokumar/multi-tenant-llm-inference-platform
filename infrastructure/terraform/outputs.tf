output "cluster_name" {
  description = "Name of the GKE Autopilot cluster."
  value       = google_container_cluster.platform.name
}

output "cluster_region" {
  description = "Region of the GKE Autopilot cluster."
  value       = google_container_cluster.platform.location
}

output "connect_command" {
  description = "Command that adds the cluster to the local kubeconfig."
  value       = "gcloud container clusters get-credentials ${google_container_cluster.platform.name} --region ${google_container_cluster.platform.location} --project ${var.project_id}"
}
