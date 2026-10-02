<?php
/**
 * Local development helper (NOT used in production).
 *
 *   Terminal 1:  python app.py                      (Flask on :5000)
 *   Terminal 2:  php -S localhost:8000 dev-router.php
 *
 * The browser code calls relative /api/... URLs. In production nginx forwards
 * those to Flask; this router does the same thing for PHP's built-in server.
 */
$path = parse_url($_SERVER["REQUEST_URI"], PHP_URL_PATH);

if (strpos($path, "/api/") !== 0) {
    return false;               // let PHP's built-in server handle pages/static files
}

$headers = "Content-Type: " . ($_SERVER["CONTENT_TYPE"] ?? "application/json") . "\r\n";
if (!empty($_SERVER["HTTP_AUTHORIZATION"])) {
    $headers .= "Authorization: " . $_SERVER["HTTP_AUTHORIZATION"] . "\r\n";
}

$context = stream_context_create(["http" => [
    "method"        => $_SERVER["REQUEST_METHOD"],
    "header"        => $headers,
    "content"       => file_get_contents("php://input"),
    "timeout"       => 15,
    "ignore_errors" => true,
]]);

$url  = "http://127.0.0.1:5000" . $_SERVER["REQUEST_URI"];
$body = @file_get_contents($url, false, $context);

if ($body === false) {
    http_response_code(502);
    header("Content-Type: application/json");
    echo json_encode(["message" => "Flask is not running on port 5000."]);
    exit;
}

$status = 200;
$respHeaders = function_exists("http_get_last_response_headers")
    ? http_get_last_response_headers() : ($http_response_header ?? []);
if (!empty($respHeaders[0]) && preg_match('#HTTP/\S+\s+(\d{3})#', $respHeaders[0], $m)) {
    $status = (int) $m[1];
}
http_response_code($status);
header("Content-Type: application/json");
echo $body;
