<?php
require_once '../config.php';

// Verify authentication
$token = getAuthToken();
if (!$token) {
    sendResponse(false, 'Unauthorized - Token required', null, 401);
}

$user = verifyToken($token);
if (!$user) {
    sendResponse(false, 'Unauthorized - Invalid token', null, 401);
}

// Get user settings
$database = readJSON(USER_SETTINGS_DB);
if ($database === null) {
    $database = ['settings' => []];
}

// Find user's settings
$userSettings = null;
foreach ($database['settings'] as $setting) {
    if ($setting['user_id'] === $user['id']) {
        $userSettings = $setting;
        break;
    }
}

// Return default settings if none exist
if ($userSettings === null) {
    $userSettings = [
        'user_id' => $user['id'],
        'notifications_enabled' => true,
        'email_notifications' => true,
        'push_notifications' => true,
        'auto_play' => true,
        'video_quality' => 'auto',
        'language' => 'en',
        'theme' => 'dark',
        'created_at' => date('Y-m-d H:i:s'),
        'updated_at' => date('Y-m-d H:i:s')
    ];
}

sendResponse(true, 'Settings retrieved successfully', ['settings' => $userSettings]);
?>
