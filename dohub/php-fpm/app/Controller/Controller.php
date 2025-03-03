<?php

namespace App\Controller;


class Controller
{
    public function response($code, $message = null, $data = null)
    {
        header('Content-Type: application/json');
        http_response_code($code);
        return json_encode(array_filter([
            'status' => $code,
            'message' => $message,
            'data' => $data,
        ]));
    }
}
