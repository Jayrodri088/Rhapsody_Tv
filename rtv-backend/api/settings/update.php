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

// Get input data
$input = json_decode(file_get_contents('php://input'), true);

if (!$input) {
    sendResponse(false, 'Invalid JSON input', null, 400);
}

// Get current settings database
$database = readJSON(USER_SETTINGS_DB);
if ($database === null) {
    $database = ['settings' => []];
}

// Find existing settings for this user
$settingsIndex = -1;
foreach ($database['settings'] as $index => $setting) {
    if ($setting['user_id'] === $user['id']) {
        $settingsIndex = $index;
        break;
    }
}

// Prepare updated settings
$updatedSettings = [
    'user_id' => $user['id'],
    'notifications_enabled' => $input['notifications_enabled'] ?? true,
    'email_notifications' => $input['email_notifications'] ?? true,
    'push_notifications' => $input['push_notifications'] ?? true,
    'auto_play' => $input['auto_play'] ?? true,
    'video_quality' => $input['video_quality'] ?? 'auto',
    'language' => $input['language'] ?? 'en',
    'theme' => $input['theme'] ?? 'dark',
    'updated_at' => date('Y-m-d H:i:s')
];

if ($settingsIndex >= 0) {
    // Update existing settings
    $updatedSettings['created_at'] = $database['settings'][$settingsIndex]['created_at'];
    $database['settings'][$settingsIndex] = $updatedSettings;
} else {
    // Create new settings
    $updatedSettings['created_at'] = date('Y-m-d H:i:s');
    $database['settings'][] = $updatedSettings;
}

// Save to database
if (writeJSON(USER_SETTINGS_DB, $database)) {
    // Log activity
    logActivity($user['id'], 'settings_updated', 'User updated their settings');

    sendResponse(true, 'Settings updated successfully', ['settings' => $updatedSettings]);
} else {
    sendResponse(false, 'Failed to update settings', null, 500);
}
?>
