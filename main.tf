// Configure the Google Cloud provider
provider "google" {
  project     = var.project_id
  region      = var.region
}

//Creating First VPC Network
resource "google_compute_network" "vpc_network" {
  name        = "kube-vpc"
  project     = var.project_id
}

//Creating Container Cluster
resource "google_container_cluster" "gke_cluster" {
  name     = "my-cluster"
  project = var.project_id
  location = var.region
  network = google_compute_network.vpc_network.name
  remove_default_node_pool = true
  initial_node_count       = 2

}

//Creating Node Pool For Container Cluster
resource "google_container_node_pool" "nodepool" {
  name       = "my-node-pool"
  project    = var.project_id
  location   = var.region
  cluster    = google_container_cluster.gke_cluster.name
  node_count = 2

  node_config {
    preemptible  = true
    machine_type = "e2-micro"
  }

  depends_on = [
    google_container_cluster.gke_cluster
  ]
}

//Configure Kubectl with Our GCP K8s Cluster
resource "null_resource" "configure_kubectl" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.gke_cluster.name} --region ${google_container_cluster.gke_cluster.location} --project ${google_container_cluster.gke_cluster.project}"
  }  

  depends_on = [
    google_container_cluster.gke_cluster
  ]
}