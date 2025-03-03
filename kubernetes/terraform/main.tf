module "module_kubernetes" {
  source       = "./infra"
  do_token     = file("../../tokens/doctl-access-token")
  do_version   = "1.32."
  region       = "sfo3"
  droplet_size = "s-4vcpu-8gb"
  min_nodes    = 1
  max_nodes    = 3
}
