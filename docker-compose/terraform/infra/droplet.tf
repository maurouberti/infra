resource "digitalocean_droplet" "droplet_docker_compose" {
  image    = var.distro_image
  name     = var.name
  region   = var.region
  size     = var.droplet_size
  ipv6     = true
  tags     = ["docker-compose", "droplet"]
  ssh_keys = [digitalocean_ssh_key.ssh_key_docker_compose.fingerprint]
}

output "droplet_docker_compose_ip_address" {
  value = digitalocean_droplet.droplet_docker_compose.ipv4_address
}
