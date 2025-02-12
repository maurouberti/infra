resource "digitalocean_record" "a_subdomain_docker_compose" {
  domain = "${var.domain}"
  type   = "A"
  name   = "${var.subdomain}"
  value  = digitalocean_droplet.droplet_docker_compose.ipv4_address
  ttl    = 1800
}

resource "digitalocean_record" "aaaa_subdomain_docker_compose" {
  domain = "${var.domain}"
  type   = "AAAA"
  name   = "${var.subdomain}"
  value  = digitalocean_droplet.droplet_docker_compose.ipv6_address
  ttl    = 1800
}
