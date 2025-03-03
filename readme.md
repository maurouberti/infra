# Docker Compose e Kubernetes na DigitalOcean

Passo a Passo para Instalação e Configuração dos Ambientes Docker Compose e Kubernetes na DigitalOcean.



## 1. Ferramentas utilizadas

As ferramentas utilizadas para a criação da Infraestrutura como Código (IaC).

### 1.1 Instalar e configurar `doctl`

O `doctl` CLI é a interface de linha de comando (Command Line Interface) oficial da DigitalOcean, usada para gerenciar recursos da plataforma.  
[Clicar aqui](https://docs.digitalocean.com/reference/doctl/how-to/install/) para consultar a referência de instalação.

> ATENÇÃO: Salvar o token no arquivo `/tokens/doctl-access-token`

### 1.2 Instalar e configurar `kubectl`

O `kubectl` CLI é a interface de linha de comando (Command Line Interface) usada para gerenciar clusters Kubernetes.  
[Clicar aqui](https://kubernetes.io/pt-br/docs/tasks/tools/) para consultar a referência de instalação.

### 1.3 Instalar e configurar o `terraform`

O `terraform` CLI é a interface de linha de comando (Command Line Interface) do Terraform, uma ferramenta da HashiCorp.  
[Clicar aqui](https://www.terraform.io/) para consultar a referência de instalação.

### 1.4 Instalar e configurar o `ansible`

O comando `ansible-playbook` é utilizado para executar playbooks no Ansible, uma ferramenta de automação utilizada para gerenciar configurações e orquestrar a execução de tarefas em sistemas remotos.
[Clicar aqui](https://docs.ansible.com/) para consultar a referência de instalação.

### 1.5 Instalar o `docker`

O `docker` deve estar instalado para realizar a construções das imagens.
[Clicar aqui](https://docs.docker.com/engine/install/) para consultar a referência de instalação.



## 2. Observações

Antes de começar altere o dominio `dominio.com.br` e `usuario-do@email.com` de todos os arquivos:

### 2.1 Criar uma SSH exclusiva para esta *infra*

```bash
ssh-keygen -t rsa -C "usuario-do@email.com" -f ./tokens/digital-ocean-id_rsa -N ""
chmod 600 ./tokens/digital-ocean-id_rsa
```



## 3. Criar as imagens `docker`

As imagens foram armazenadas no `Container Registry` da DigitalOcean.

### 3.1 Criar **dohub**

```bash
doctl registry create dohub --region=sfo3
```

### 3.2 Gerar imagens

```bash
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

### 4.1 Criar infraestrutura

Navegue até a pasta `docker-compose/terraform/` e execute o seguinte comando:

```bash
terraform init
terraform apply -auto-approve
```

### 4.2 Instalação e configurações

Navegue até a pasta `docker-compose/ansible/` e execute o seguinte comando:

```bash
ansible-playbook ./playbook.yaml -i ./hosts
```

### 4.3 Criar database

https://dc.dominio.com.br/usuarios/database



## 5. Criar ambiente `kubernetes`

### 5.1 Criar infraestrutura

Navegue até a pasta `kubernetes/terraform/` e execute o seguinte comando:

```bash
terraform init
terraform apply -auto-approve
```

### 5.2 Instalação e configurações

Navegue até a pasta `kubernetes/kubectl/` e execute o seguinte comando:


```bash
kubectl create secret docker-registry registry-dohub \
  --docker-server=registry.digitalocean.com \
  --docker-username=usuario-do@email.com \
  --docker-password="$(cat ../../tokens/doctl-access-token)" \
  --docker-email=usuario-do@email.com \
  --namespace=projeto
```

```bash
kubectl apply -f ./namespace.yaml
kubectl apply -f ./mysql.yaml
kubectl apply -f ./phpfpm.yaml
doctl compute certificate create --type lets_encrypt --name cert-k8s --dns-names k8s.dominio.com.br
kubectl apply -f ./nginx.yaml
# aguarde
doctl compute domain records create dominio.com.br --record-type A --record-name k8s --record-ttl 1800 --record-data $(kubectl get svc -n projeto | grep nginx-load-balancer | awk '{print $4}' | cut -d ',' -f 1)
doctl compute domain records create dominio.com.br --record-type AAAA --record-name k8s --record-ttl 1800 --record-data $(kubectl get svc -n projeto | grep nginx-load-balancer | awk '{print $4}' | cut -d ',' -f 2)
```

HPA

```bash
kubectl apply -f ./metrics-server.yaml
kubectl apply -f ./phpfpm-hpa.yaml
kubectl apply -f ./nginx-hpa.yaml
```

### 5.3 Criar database

https://k8s.dominio.com.br/usuarios/database



## 6. Criar ambiente `locust`

### 6.1 Criar infraestrutura

Navegue até a pasta `locust/terraform/` e execute o seguinte comando:

```bash
terraform init
terraform apply -auto-approve
```

### 6.2 Instalação e configurações

Navegue até a pasta `locust/ansible/` e execute o seguinte comando:

```bash
ansible-playbook ./playbook.yaml -i ./hosts
```



## 7 Exclusão

```bash
cd ./locust/terraform
terraform destroy -auto-approve

cd ./docker-compose/terraform
terraform destroy -auto-approve

cd ./kubernetes/terraform
terraform destroy -auto-approve

doctl compute volume delete $(doctl compute volume list --no-header | awk '{print $1}') --force
doctl compute load-balancer delete $(doctl compute load-balancer list --no-header | awk '{print $1}') --force
doctl compute domain records delete dominio.com.br $(doctl compute domain records list dominio.com.br | grep k8s | grep -v www | awk '{print $1}') --force
doctl compute certificate delete $(doctl compute certificate list --no-header | awk '{print $1}') --force
doctl registry delete dohub
```
