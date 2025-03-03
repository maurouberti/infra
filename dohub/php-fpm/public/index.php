<?php

use App\Controller\Controller;

require "../vendor/autoload.php";
require "../app/env.php";
require "../app/routes.php";

try {
    loadEnv();

    $uri = parse_url($_SERVER['REQUEST_URI'])['path'];
    $method = $_SERVER['REQUEST_METHOD'];

    if (!isset($router[$method])) {
        throw new Exception("A rota não existe");
    }

    if (!array_key_exists($uri, $router[$method])) {
        throw new Exception("A rota não existe");
    }

    $controller = $router[$method][$uri];
    $controller();
} catch (Exception $e) {
    echo (new Controller())->response(400, $e->getMessage());
}
