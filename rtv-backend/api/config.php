<?php
// API-specific configuration with JSON headers
// Only include this in API endpoints, NOT in admin pages

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Include shared functions without headers
require_once __DIR__ . '/functions.php';
?>
