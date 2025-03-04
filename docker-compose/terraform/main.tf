module "module_docker_compose" {
  source       = "./infra"
  do_token     = file("../../tokens/doctl-access-token")
  pub_key      = file("../../tokens/digital-ocean-id_rsa.pub")
  name         = "docker-compose"
  subdomain    = "dc"
  domain       = "sane-maquiagem.com.br"
  distro_image = "ubuntu-24-04-x64"
  region       = "sfo3"
  droplet_size = "s-4vcpu-8gb"
}

output "ip_address_droplet" {
  value       = module.module_docker_compose.droplet_docker_compose_ip_address
  description = "IP externo do droplet."
}

output "ip_address_loadbalancer" {
  value       = module.module_docker_compose.loadbalancer_docker_compose_ip_address
  description = "IP externo do loadbalancer."
}
