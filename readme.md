# Docker Compose e Kubernetes na DigitalOcean

Passo a Passo para Instalação e Configuração dos Ambientes Docker Compose e Kubernetes na DigitalOcean.



## 1. Ferramentas utilizadas

As ferramentas utilizadas para a criação da Infraestrutura como Código (IaC).

### 1.1 Instalar e configurar `doctl`

O `doctl` CLI é a interface de linha de comando (Command Line Interface) oficial da DigitalOcean, usada para gerenciar recursos da plataforma.  
[Clicar aqui](https://docs.digitalocean.com/reference/doctl/how-to/install/) para consultar a referência de instalação.

### 1.2 Instalar e configurar `kubectl`

O `kubectl` CLI é a interface de linha de comando (Command Line Interface) usada para gerenciar clusters Kubernetes.  
[Clicar aqui](https://kubernetes.io/pt-br/docs/tasks/tools/) para consultar a referência de instalação.

### 1.3 Instalar e configurar o `terraform`

O `terraform` CLI é a interface de linha de comando (Command Line Interface) do Terraform, uma ferramenta da HashiCorp.  
[Clicar aqui](https://www.terraform.io/) para consultar a referência de instalação.



## 2. Criar as imagens `docker`

As imagens foram armazenadas no `Container Registry` da DigitalOcean.

### 2.1 Criar **dohub**

```bash
doctl registry create dohub --region=sfo3
```

### 2.2 Gerar imagens

```bash
docker build -t registry.digitalocean.com/dohub/maurouberti/nginx:latest dohub/nginx
docker tag registry.digitalocean.com/dohub/maurouberti/nginx:latest registry.digitalocean.com/dohub/maurouberti/nginx:1.0
docker push --all-tags registry.digitalocean.com/dohub/maurouberti/nginx
docker rmi -f registry.digitalocean.com/dohub/maurouberti/nginx:latest -f registry.digitalocean.com/dohub/maurouberti/nginx:1.0

docker build -t registry.digitalocean.com/dohub/maurouberti/php-fpm:latest dohub/php-fpm
docker tag registry.digitalocean.com/dohub/maurouberti/php-fpm:latest registry.digitalocean.com/dohub/maurouberti/php-fpm:1.0
docker push --all-tags registry.digitalocean.com/dohub/maurouberti/php-fpm
docker rmi -f registry.digitalocean.com/dohub/maurouberti/php-fpm:latest -f registry.digitalocean.com/dohub/maurouberti/php-fpm:1.0

docker build -t registry.digitalocean.com/dohub/maurouberti/mysql:latest dohub/mysql
docker tag registry.digitalocean.com/dohub/maurouberti/mysql:latest registry.digitalocean.com/dohub/maurouberti/mysql:1.0
docker push --all-tags registry.digitalocean.com/dohub/maurouberti/mysql
docker rmi -f registry.digitalocean.com/dohub/maurouberti/mysql:latest -f registry.digitalocean.com/dohub/maurouberti/mysql:1.0

docker build -t registry.digitalocean.com/dohub/maurouberti/locust:latest dohub/locust
docker tag registry.digitalocean.com/dohub/maurouberti/locust:latest registry.digitalocean.com/dohub/maurouberti/locust:1.0
docker push --all-tags registry.digitalocean.com/dohub/maurouberti/locust
docker rmi -f registry.digitalocean.com/dohub/maurouberti/locust:latest -f registry.digitalocean.com/dohub/maurouberti/locust:1.0

docker system prune
```



## 3. Criar ambiente `docker-compose`

### 3.1 Criar uma SSH exclusiva para esta *infra*

```bash
ssh-keygen -t rsa -C "maurouberti@hotmail.com" -f ./tokens/docker-compose-id_rsa -N ""
chmod 600 ./tokens/docker-compose-id_rsa
```

### 3.2 Criar infraestrutura

Navegue até a pasta `docker-compose/create-droplet/` e execute o seguinte comando:

```bash
terraform init
terraform apply -auto-approve
```

### 3.3 Instalação e configurações

Navegue até a pasta `docker-compose/install/` e execute o seguinte comando:

```bash
ansible-playbook ./playbook-1-install.yaml -i ./hosts --private-key=./tokens/docker-compose-id_rsa
ansible-playbook ./playbook-2-certificate.yaml -i ./hosts --private-key=./tokens/docker-compose-id_rsa
ansible-playbook ./playbook-3-app.yaml -i ./hosts --private-key=./tokens/docker-compose-id_rsa
```

> ATENÇÃO: Se for **windows**, entrar no prompt `WSL` (ansible não tem para windows)



## 4. Criar ambiente `kubernetes`

### 4.1 Criar infraestrutura

Navegue até a pasta `kubernetes/create-cluster/` e execute o seguinte comando:

```bash
terraform init
terraform apply -auto-approve
```

### 4.2 Instalação e configurações

Navegue até a pasta `kubernetes/install/` e execute o seguinte comando:

```bash
kubectl apply -f ./namespace.yaml
```

Criar e configurar um serviço `php-fph`

```bash
kubectl apply -f ./phpfpm-configmap.yaml
kubectl apply -f ./phpfpm-secret.yaml
kubectl apply -f ./phpfpm-deployment.yaml
kubectl apply -f ./phpfpm-service.yaml
kubectl apply -f ./phpfpm-hpa.yaml
```

Criar um `certificado` SSL/TLS usando o Let's Encrypt na DigitalOcean.

```bash
doctl compute certificate create --type lets_encrypt --name cert-k8s --dns-names k8s.dominio.com.br
```

Criar e configurar um serviço `nginx`

```bash
kubectl apply -f ./nginx-configmap.yaml
kubectl apply -f ./nginx-deployment.yaml
kubectl apply -f ./nginx-load-balancer.yaml
```

Aguardar a criação do load balancer antes de registrar o DNS do `domínio`.

```bash
doctl compute domain records create dominio.com.br --record-type A --record-name k8s --record-ttl 1800 --record-data $(kubectl get svc -n projeto | grep nginx-phpfpm-load-balancer | awk '{print $4}')
```

Criar e configurar um serviço `mysql`

```bash
kubectl apply -f ./mysql-pvc.yaml
kubectl apply -f ./mysql-secret.yaml
kubectl apply -f ./mysql-statefulset.yaml
kubectl apply -f ./mysql-service.yaml
```

Criar o banco de dados

```bash
kubectl apply -f ./mysql-job.yaml
kubectl delete -f ./mysql-job.yaml
```

Criar e configurar um serviço `locust` (teste de carga)

```bash
kubectl apply -f ./locust-deployment.yaml
kubectl apply -f ./locust-service.yaml
```

Fazer o redirecionamento de porta (port-forwarding) do `locust` para sua máquina local.

```bash
kubectl port-forward svc/locust-svc -n projeto 9000:8089
```

Acessar por http://localhost:9000/
