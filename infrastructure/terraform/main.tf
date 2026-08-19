locals {
  required_services = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
  ])
}

resource "google_project_service" "required" {
  for_each = local.required_services

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_compute_network" "platform" {
  project                 = var.project_id
  name                    = "llm-inference-lab"
  auto_create_subnetworks = false

  depends_on = [google_project_service.required]
}

resource "google_compute_subnetwork" "platform" {
  project       = var.project_id
  name          = "llm-inference-lab-${var.region}"
  region        = var.region
  network       = google_compute_network.platform.id
  ip_cidr_range = "10.10.0.0/20"

  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = "10.20.0.0/16"
  }

  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = "10.30.0.0/20"
  }
}

resource "google_service_account" "gke_nodes" {
  project      = var.project_id
  account_id   = "gke-autopilot-nodes"
  display_name = "GKE Autopilot node service account"

  depends_on = [google_project_service.required]
}

resource "google_project_iam_member" "gke_nodes" {
  project = var.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_container_cluster" "platform" {
  project  = var.project_id
  name     = var.cluster_name
  location = var.region

  enable_autopilot    = true
  deletion_protection = false

  network    = google_compute_network.platform.id
  subnetwork = google_compute_subnetwork.platform.id

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }

  release_channel {
    channel = "REGULAR"
  }

  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = google_service_account.gke_nodes.email
    }
  }

  resource_labels = {
    environment = "lab"
    project     = "multi-tenant-llm-inference"
  }

  depends_on = [
    google_project_iam_member.gke_nodes,
    google_project_service.required,
  ]
}
