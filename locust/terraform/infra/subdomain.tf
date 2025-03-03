resource "digitalocean_record" "a_subdomain_locust" {
  domain = "${var.domain}"
  type   = "A"
  name   = "locust"
  value  = digitalocean_droplet.droplet_locust.ipv4_address
  ttl    = 1800
}

resource "digitalocean_record" "aaaa_subdomain_locust" {
  domain = "${var.domain}"
  type   = "AAAA"
  name   = "locust"
  value  = digitalocean_droplet.droplet_locust.ipv6_address
  ttl    = 1800
}
