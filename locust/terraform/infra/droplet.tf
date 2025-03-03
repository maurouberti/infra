resource "digitalocean_droplet" "droplet_locust" {
  image    = var.distro_image
  name     = "locust"
  region   = var.region
  size     = var.droplet_size
  ipv6     = true
  tags     = ["locust", "droplet"]
  ssh_keys = [data.digitalocean_ssh_key.existing_ssh_key.id]
}

output "droplet_locust_ip_address" {
  value = digitalocean_droplet.droplet_locust.ipv4_address
}
