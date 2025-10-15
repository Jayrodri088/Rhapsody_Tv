<?php
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse(false, 'Method not allowed', null, 405);
}

$token = getAuthToken();
if (!$token) {
    sendResponse(false, 'Authorization token required', null, 401);
}

$user = verifyToken($token);
if (!$user) {
    sendResponse(false, 'Invalid or expired token', null, 401);
}

$database = readJSON(USERS_DB);
if ($database === null) {
    sendResponse(false, 'Database error', null, 500);
}

// Find and clear the user's token
$userIndex = null;
foreach ($database['users'] as $index => $dbUser) {
    if ($dbUser['id'] === $user['id']) {
        $userIndex = $index;
        break;
    }
}

if ($userIndex === null) {
    sendResponse(false, 'User not found', null, 404);
}

// Clear the token
$database['users'][$userIndex]['token'] = null;

if (writeJSON(USERS_DB, $database)) {
    sendResponse(true, 'Logout successful');
} else {
    sendResponse(false, 'Failed to logout', null, 500);
}
?>
