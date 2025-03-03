module "module_locust" {
  source       = "./infra"
  do_token     = file("../../tokens/doctl-access-token")
  domain       = "dominio.com.br"
  distro_image = "ubuntu-24-04-x64"
  region       = "sfo3"
  droplet_size = "s-4vcpu-8gb"
}

output "ip_address" {
  value       = module.module_locust.droplet_locust_ip_address
  description = "IP externo do Droplet."
}
