variable "region" {
  default = "us-central1"
}
variable "project" {
  default = "sohansm-project"
}
variable "image" {
  default = "us-central1-docker.pkg.dev/sohansm-project/cloud-run-source-deploy/hello-node-fn@sha256:946913721682430c224d87650fe686d989ee4341d5b1a1f55c5697a8b06c12dd"
}

variable "name" {
  default = "hello-node-fn"
}

resource "google_cloudbuild_trigger" "trigger" {
  name        = "cloud-build-trigger"
  description = "A trigger to build my app"
  location    = var.region

  github {
    owner = "sohansm"
    name  = "hello-node-fn"
    push {
      branch = "^main$" # Trigger on pushes to the main branch
    }
  }

  # Build configuration
  filename = "cloudbuild.yaml" # Use a Cloud Build configuration file
}

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.7.0"
    }
  }
}
provider "google" {
  project = var.project
}

provider "google-beta" {
  project = var.project
}

resource "google_cloud_run_v2_service" "hello-node-fn" {
  name = var.name
  location = var.region
  provider = google-beta
  launch_stage = "BETA"
  deletion_protection=false
  template {
    #service_account = var.service-account
    service_account = "1000276527499-compute@developer.gserviceaccount.com"
    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"
    # labels = {
    #    "run.googleapis.com/startupProbeType" = "Default"
    # }

    containers {
      image = var.image

      resources {
        limits = {
          cpu = "2000m"
          memory = "1Gi"
        }
      }
    }

    # vpc_access{
    #   network_interfaces {
    #     network = google_compute_network.vpc.name
    #     subnetwork = google_compute_subnetwork.subnet.name
    #   }
    #   egress = "PRIVATE_RANGES_ONLY"
    # }

  }

  traffic {
    percent         = 100
     type = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }

}