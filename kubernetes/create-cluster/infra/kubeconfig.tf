# Cria um arquivo de configuração Kubernetes local que permite que você interaja com o cluster da DigitalOcean de maneira simples e integrada.
# Facilita o uso do `kubectl` e de outras ferramentas que requerem um arquivo kubeconfig.

resource "local_file" "kubeconfig" {
  filename   = "${pathexpand("~")}/.kube/config"
  content    = data.digitalocean_kubernetes_cluster.data_cluster_k8s.kube_config[0].raw_config
}

provider "kubernetes" {
  config_path = "${pathexpand("~")}/.kube/config"
  host        = data.digitalocean_kubernetes_cluster.data_cluster_k8s.endpoint
  token       = data.digitalocean_kubernetes_cluster.data_cluster_k8s.kube_config[0].token
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.data_cluster_k8s.kube_config[0].cluster_ca_certificate
  )
}
