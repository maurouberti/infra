<?php

namespace App\Repository;

use Exception;
use mysqli;

class DatabaseRepository
{
    private $conn;
    private $dbname;

    public function __construct()
    {
        $host = getenv('DB_HOST');
        $port = getenv('DB_PORT');
        $this->dbname = getenv('DB_DATABASE');
        $username = getenv('DB_USERNAME');
        $password = getenv('DB_PASSWORD');

        $this->conn = new mysqli($host, $username, $password);
        if ($this->conn->connect_error) {
            throw new Exception("Connection failed: " . $this->conn->connect_error);
        }
    }

    public function dropDatabase()
    {
        $sql = "DROP DATABASE IF EXISTS $this->dbname";
        if ($this->conn->query($sql) === false) {
            throw new Exception("Error ddroping database: " . $this->conn->error);
        }
    }

    public function createDatabase()
    {
        $sql = "CREATE DATABASE IF NOT EXISTS $this->dbname";
        if ($this->conn->query($sql) === false) {
            throw new Exception("Error creating database: " . $this->conn->error);
        }
    }

    public function createTable()
    {
        $this->conn->select_db($this->dbname);
        $sql = "CREATE TABLE IF NOT EXISTS `users` (
                    `id` bigint unsigned NOT NULL AUTO_INCREMENT,
                    `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
                    `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
                    `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
                    PRIMARY KEY (`id`),
                    UNIQUE KEY `users_email_unique` (`email`)
                ) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;";
        if ($this->conn->query($sql) === false) {
            throw new Exception("Error creating table: " . $this->conn->error);
        }
    }

    public function close()
    {
        $this->conn->close();
    }
}
