resource "digitalocean_ssh_key" "ssh_key_docker_compose" {
  name       = "DockerComposeSSH.pub"
  public_key = var.pub_key
}
