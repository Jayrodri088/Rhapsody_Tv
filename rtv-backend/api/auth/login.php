<?php
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse(false, 'Method not allowed', null, 405);
}

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['email']) || !isset($input['password'])) {
    sendResponse(false, 'Email and password are required', null, 400);
}

$email = sanitizeInput($input['email']);
$password = $input['password'];

if (!validateEmail($email)) {
    sendResponse(false, 'Invalid email format', null, 400);
}

$database = readJSON(USERS_DB);
if ($database === null) {
    sendResponse(false, 'Database error', null, 500);
}

$user = null;
$userIndex = null;
foreach ($database['users'] as $index => $dbUser) {
    if ($dbUser['email'] === $email) {
        $user = $dbUser;
        $userIndex = $index;
        break;
    }
}

if ($user === null) {
    sendResponse(false, 'Invalid email or password', null, 401);
}

if (!password_verify($password, $user['password'])) {
    sendResponse(false, 'Invalid email or password', null, 401);
}

$newToken = generateToken();
$database['users'][$userIndex]['token'] = $newToken;
$database['users'][$userIndex]['last_login'] = date('Y-m-d H:i:s');

if (writeJSON(USERS_DB, $database)) {
    unset($user['password']);
    $user['token'] = $newToken;
    $user['last_login'] = $database['users'][$userIndex]['last_login'];
    sendResponse(true, 'Login successful', ['user' => $user]);
} else {
    sendResponse(false, 'Failed to update user', null, 500);
}
?>
