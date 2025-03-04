resource "digitalocean_certificate" "cert_k8s" {
  name    = "cert-k8s"
  type    = "lets_encrypt"
  domains = ["${var.subdomain}.${var.domain}"]
}
