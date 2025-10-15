<?php
require_once '../config.php';

$token = getAuthToken();
if (!$token) {
    sendResponse(false, 'Authorization token required', null, 401);
}

$user = verifyToken($token);
if (!$user) {
    sendResponse(false, 'Invalid or expired token', null, 401);
}

// GET - Get user profile
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    unset($user['password']);
    sendResponse(true, 'Profile retrieved successfully', ['user' => $user]);
}

// PUT - Update user profile
if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    $input = json_decode(file_get_contents('php://input'), true);

    $database = readJSON(USERS_DB);
    if ($database === null) {
        sendResponse(false, 'Database error', null, 500);
    }

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

    // Update fields if provided (name is not editable)
    if (isset($input['phone_number'])) {
        $database['users'][$userIndex]['phone_number'] = sanitizeInput($input['phone_number']);
    }

    if (isset($input['profile_image'])) {
        $database['users'][$userIndex]['profile_image'] = sanitizeInput($input['profile_image']);
    }

    $database['users'][$userIndex]['updated_at'] = date('Y-m-d H:i:s');

    if (writeJSON(USERS_DB, $database)) {
        $updatedUser = $database['users'][$userIndex];
        unset($updatedUser['password']);
        sendResponse(true, 'Profile updated successfully', ['user' => $updatedUser]);
    } else {
        sendResponse(false, 'Failed to update profile', null, 500);
    }
}

sendResponse(false, 'Method not allowed', null, 405);
?>
