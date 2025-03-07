data "digitalocean_kubernetes_versions" "versions_k8s" {
  version_prefix = var.do_version
}

resource "digitalocean_kubernetes_cluster" "cluster_k8s" {
  name    = "cluster"
  region  = var.region
  version = data.digitalocean_kubernetes_versions.versions_k8s.latest_version
  tags    = ["kubernetes", "cluster", "projeto"]

  node_pool {
    name       = "kubernetes"
    size       = var.droplet_size
    auto_scale = true
    min_nodes  = var.min_nodes
    max_nodes  = var.max_nodes
    tags       = ["kubernetes", "droplet", "projeto"]
  }
}

data "digitalocean_kubernetes_cluster" "data_cluster_k8s" {
  name = digitalocean_kubernetes_cluster.cluster_k8s.name
}
