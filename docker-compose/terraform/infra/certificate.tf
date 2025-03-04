resource "digitalocean_certificate" "cert_docker_compose" {
  name    = "cert-dc"
  type    = "lets_encrypt"
  domains = ["lb.${var.domain}"]
}
