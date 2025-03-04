# Docker Compose e Kubernetes na DigitalOcean

Passo a Passo para Instalação e Configuração dos Ambientes Docker Compose e Kubernetes na DigitalOcean.



## 1. Ferramentas utilizadas

As ferramentas utilizadas para a criação da Infraestrutura como Código (IaC).

[doctl](https://docs.digitalocean.com/reference/doctl/how-to/install/), 
[kubectl](https://kubernetes.io/pt-br/docs/tasks/tools/), 
[terraform](https://www.terraform.io/), 
[ansible](https://docs.ansible.com/) e 
[docker](https://docs.docker.com/engine/install/)



## 2. Observações

* Antes de começar altere o dominio `dominio.com.br` e `usuario-do@email.com` de todos os arquivos  
* Salvar o token no arquivo `/tokens/doctl-access-token`  
* Criar uma SSH exclusiva para esta *infra*:

```bash
ssh-keygen -t rsa -C "usuario-do@email.com" -f ./tokens/digital-ocean-id_rsa -N ""
chmod 600 ./tokens/digital-ocean-id_rsa
```



## 3. Criar as imagens `docker`

As imagens foram armazenadas no `Container Registry` da DigitalOcean.

```bash
doctl registry create dohub --region=sfo3

docker build -t registry.digitalocean.com/dohub/maurouberti/php-fpm:latest ./dohub/php-fpm
docker push --all-tags registry.digitalocean.com/dohub/maurouberti/php-fpm

docker build -t registry.digitalocean.com/dohub/maurouberti/locust:latest ./dohub/locust
docker push --all-tags registry.digitalocean.com/dohub/maurouberti/locust

docker build -t registry.digitalocean.com/dohub/maurouberti/nginx:latest ./dohub/nginx
docker push --all-tags registry.digitalocean.com/dohub/maurouberti/nginx

docker build -t registry.digitalocean.com/dohub/maurouberti/mysql:latest ./dohub/mysql
docker push --all-tags registry.digitalocean.com/dohub/maurouberti/mysql
```



## 4. Criar ambiente `docker-compose`

```bash
# Navegue até a pasta `docker-compose/terraform/`
terraform init
terraform apply -auto-approve

# Navegue até a pasta `docker-compose/ansible/`
ansible-playbook ./playbook.yaml -i ./hosts
```

> https://lb.dominio.com.br/usuarios/database



## 5. Criar ambiente `kubernetes`

```bash
# Navegue até a pasta `kubernetes/terraform/`
terraform init
terraform apply -auto-approve

# Navegue até a pasta `kubernetes/kubectl/`
kubectl apply -f ./namespace.yaml

kubectl create secret docker-registry registry-dohub \
  --docker-server=registry.digitalocean.com \
  --docker-username=usuario-do@email.com \
  --docker-password="$(cat ../../tokens/doctl-access-token)" \
  --docker-email=usuario-do@email.com \
  --namespace=projeto

kubectl apply -f ./mysql.yaml
kubectl apply -f ./phpfpm.yaml
kubectl apply -f ./nginx.yaml
kubectl apply -f ./metrics-server.yaml
kubectl apply -f ./phpfpm-hpa.yaml
kubectl apply -f ./nginx-hpa.yaml

# aguarde a criação do loadbalancer
doctl compute domain records create dominio.com.br --record-type A --record-name k8s --record-ttl 1800 --record-data $(kubectl get svc -n projeto | grep nginx-load-balancer | awk '{print $4}' | cut -d ',' -f 1)
doctl compute domain records create dominio.com.br --record-type AAAA --record-name k8s --record-ttl 1800 --record-data $(kubectl get svc -n projeto | grep nginx-load-balancer | awk '{print $4}' | cut -d ',' -f 2)
```

> https://k8s.dominio.com.br/usuarios/database



## 6. Criar ambiente `locust`

```bash
# Navegue até a pasta `locust/terraform/`
terraform init
terraform apply -auto-approve

# Navegue até a pasta `locust/ansible/`
ansible-playbook ./playbook.yaml -i ./hosts
```

> https://locust.dominio.com.br:8001 e https://locust.dominio.com.br:8002



## 7. Exclusão

```bash
# Navegue até a pasta `locust/terraform/`
terraform destroy -auto-approve

# Navegue até a pasta `docker-compose/terraform/`
terraform destroy -auto-approve

# Navegue até a pasta `kubernetes/terraform/`
terraform destroy -auto-approve

doctl compute volume delete $(doctl compute volume list --no-header | awk '{print $1}') --force
doctl compute load-balancer delete $(doctl compute load-balancer list --no-header | awk '{print $1}') --force
doctl compute domain records delete dominio.com.br $(doctl compute domain records list dominio.com.br | grep k8s | grep -v www | awk '{print $1}') --force
doctl compute certificate delete $(doctl compute certificate list --no-header | awk '{print $1}') --force
doctl registry delete dohub
```
