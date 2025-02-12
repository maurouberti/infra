import random
import string
import time
from locust import FastHttpUser, task, between

def gerar_email_aleatorio():
    dominios = ['gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com']
    nome_usuario = ''.join(random.choices(string.ascii_lowercase + string.digits, k=10))
    dominio = random.choice(dominios)
    return f"{nome_usuario}@{dominio}"

def gerar_nome_aleatorio():
    letras = string.ascii_uppercase + string.ascii_lowercase
    nome = ''.join(random.choices(letras, k=10))
    return nome

class TesteCarga(FastHttpUser):
    # host = "http://dc.dominio.svc.cluster.local"
    # wait_time = between(1, 3)
    wait_time = lambda self: 0

    @task(2)
    def test_api_usuario(self):
        self.client.get("/usuarios/")

    @task(1)
    def test_criar_e_logar_usuario(self):
        email_aleatorio = gerar_email_aleatorio()
        nome_aleatorio = gerar_nome_aleatorio()
        response = self.client.post("/usuarios/novo", json={"email": email_aleatorio, "password": "123456", "name": nome_aleatorio})
        if response.status_code == 200:
            self.client.post("/usuarios/entrar", json={"email": email_aleatorio, "password": "123456"})

    @task(1)
    def test_listar_usuarios(self):
        self.client.get(f"/usuarios/listar?pagina=1", name="/usuarios/listar")
