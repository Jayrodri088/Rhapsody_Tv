<?php
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse(false, 'Method not allowed', null, 405);
}

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['name']) || !isset($input['email']) || !isset($input['password'])) {
    sendResponse(false, 'Name, email and password are required', null, 400);
}

$name = sanitizeInput($input['name']);
$email = sanitizeInput($input['email']);
$password = $input['password'];
$confirmPassword = $input['confirm_password'] ?? '';

if (strlen($name) < 2) {
    sendResponse(false, 'Name must be at least 2 characters', null, 400);
}

if (!validateEmail($email)) {
    sendResponse(false, 'Invalid email format', null, 400);
}

if (strlen($password) < 6) {
    sendResponse(false, 'Password must be at least 6 characters', null, 400);
}

if ($password !== $confirmPassword) {
    sendResponse(false, 'Passwords do not match', null, 400);
}

$database = readJSON(USERS_DB);
if ($database === null) {
    sendResponse(false, 'Database error', null, 500);
}

foreach ($database['users'] as $user) {
    if ($user['email'] === $email) {
        sendResponse(false, 'Email already registered', null, 409);
    }
}

$newUser = [
    'id' => uniqid('user_', true),
    'name' => $name,
    'email' => $email,
    'password' => password_hash($password, PASSWORD_DEFAULT),
    'created_at' => date('Y-m-d H:i:s'),
    'token' => generateToken()
];

$database['users'][] = $newUser;

if (writeJSON(USERS_DB, $database)) {
    unset($newUser['password']);
    sendResponse(true, 'Registration successful', ['user' => $newUser], 201);
} else {
    sendResponse(false, 'Failed to save user', null, 500);
}
?>
