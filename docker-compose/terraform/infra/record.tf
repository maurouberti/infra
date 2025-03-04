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

resource "digitalocean_record" "a_subdomain_loadbalancer" {
  domain = "${var.domain}"
  type   = "A"
  name   = "lb"
  value  = digitalocean_loadbalancer.loadbalancer_docker_compose.ip
  ttl    = 1800
}

resource "digitalocean_record" "aaaa_subdomain_loadbalancer" {
  domain = "${var.domain}"
  type   = "AAAA"
  name   = "lb"
  value  = digitalocean_loadbalancer.loadbalancer_docker_compose.ipv6
  ttl    = 1800
}
