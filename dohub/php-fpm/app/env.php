<?php

function loadEnv()
{
    $filePath = "../.env";
    if (!file_exists($filePath)) {
        throw new Exception("Arquivo .env não encontrado.");
    }

    $lines = file($filePath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

    foreach ($lines as $line) {
        // Ignorar comentários
        if (substr(trim($line), 0, 1) == '#') {
            continue;
        }

        // Quebra a linha em chave e valor
        [$key, $value] = explode('=', $line, 2);

        // Remove espaços e aspas desnecessárias
        $key = trim($key);
        $value = trim($value, " \t\n\r\0\x0B\"'");

        // Só define a variável se ela ainda não estiver definida
        if (!getenv($key)) {
            putenv("$key=$value");
            $_ENV[$key] = $value;
            $_SERVER[$key] = $value;
        }
    }
}
