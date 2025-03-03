<?php

namespace App\Repository;

use PDO;
use PDOException;

class UsuarioRepository
{
    private $pdo;

    public function __construct()
    {
        $host = getenv('DB_HOST');
        $port = getenv('DB_PORT');
        $dbname = getenv('DB_DATABASE');
        $username = getenv('DB_USERNAME');
        $password = getenv('DB_PASSWORD');
        try {
            $dsn = "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4";
            $this->pdo = new PDO($dsn, $username, $password);
            $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch (PDOException $e) {
            die("Erro na conexão com o banco de dados: " . $e->getMessage());
        }
    }

    public function new($name, $email, $password): bool
    {
        try {
            $sql = "INSERT INTO users (name, email, password) VALUES (:name, :email, :password)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':name', $name);
            $stmt->bindParam(':email', $email);
            $passwordCrypt = password_hash($password, PASSWORD_DEFAULT);
            $stmt->bindParam(':password', $passwordCrypt);
            $stmt->execute();
            return true;
        } catch (PDOException $e) {
            return false;
        }
    }

    public function validate($email, $password): bool
    {
        try {
            $sql = "SELECT password FROM users WHERE email = :email";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':email', $email);
            $stmt->execute();
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            if ($user && password_verify($password, $user['password'])) {
                return true;
            }
            return false;
        } catch (PDOException $e) {
            return false;
        }
    }

    public function zap(): bool
    {
        try {
            $sql = "DELETE FROM users";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            return true;
        } catch (PDOException $e) {
            return false;
        }
    }

    public function list($page)
    {
        try {
            $offset = (10 * $page) - 10;
            $sql = "SELECT id, name, email FROM users LIMIT 10 OFFSET :offset";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
            $stmt->execute();
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            return false;
        }
    }
}
