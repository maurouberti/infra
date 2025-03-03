<?php

function load(string $controller, string $action)
{
    try {
        $controllerNamespace = "App\\Controller\\{$controller}";
        if (!class_exists($controllerNamespace)) {
            throw new Exception("O controller: {$controller} não existe.");
        }

        $controllerInstance = new $controllerNamespace();
        if (!method_exists($controllerInstance, $action)) {
            throw new Exception("O método: {$action} não existe no controller: {$controller}");
        }


        // Determinar os dados com base no método HTTP
        $data = null;
        if ($_SERVER['REQUEST_METHOD'] === 'GET') {
            $data = (object)$_GET;
        } elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $body = file_get_contents('php://input');
            $data = (object)(json_decode($body, true) ?: $_POST);
        } else {
            throw new Exception("Método HTTP não suportado: {$_SERVER['REQUEST_METHOD']}");
        }

        // Chamar o método no controller
        echo $controllerInstance->$action($data);
    } catch (Exception $e) {
        echo json_encode([
            'error' => $e->getMessage()
        ]);
    }
}

$prefix = "/usuarios";

$router = [
    "GET" => [
        "$prefix/" => function () {
            return load("UsuarioController", "home");
        },
        "$prefix/listar" => function () {
            return load("UsuarioController", "list");
        },
        "$prefix/database" => function () {
            return load("UsuarioController", "database");
        },
    ],
    "POST" => [
        "$prefix/entrar" => function () {
            return load("UsuarioController", "login");
        },
        "$prefix/novo" => function () {
            return load("UsuarioController", "store");
        },
    ]
];
