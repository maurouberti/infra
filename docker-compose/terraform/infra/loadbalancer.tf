resource "digitalocean_certificate" "cert_docker_compose" {
  name    = "cert-dc"
  type    = "lets_encrypt"
  domains = ["lb.${var.domain}"]
}

resource "digitalocean_loadbalancer" "loadbalancer_docker_compose" {
  name   = "loadbalancer-${var.name}"
  region = var.region

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = 80
    target_protocol = "http"

    certificate_name = digitalocean_certificate.cert_docker_compose.name
  }

  healthcheck {
    port     = 22
    protocol = "tcp"
  }

  droplet_ids = [digitalocean_droplet.droplet_docker_compose.id]
}

output "loadbalancer_docker_compose_ip_address" {
  value = digitalocean_loadbalancer.loadbalancer_docker_compose.ip
}
