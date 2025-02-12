data "digitalocean_kubernetes_versions" "versions_k8s" {
  version_prefix = var.do_version
}

resource "digitalocean_kubernetes_cluster" "cluster_k8s" {
  name    = "cluster-${var.name}"
  region  = var.region
  version = data.digitalocean_kubernetes_versions.versions_k8s.latest_version
  tags    = ["kubernetes", "cluster"]

  node_pool {
    name       = "droplet-${var.name}"
    size       = var.droplet_size
    auto_scale = true
    min_nodes  = var.min_nodes
    max_nodes  = var.max_nodes
    tags       = ["kubernetes", "droplet"]
  }
}

data "digitalocean_kubernetes_cluster" "data_cluster_k8s" {
  name = digitalocean_kubernetes_cluster.cluster_k8s.name
}
