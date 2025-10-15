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

if (!isset($input['notification_id'])) {
    sendResponse(false, 'Notification ID is required', null, 400);
}

$notificationId = sanitizeInput($input['notification_id']);

// Get notification views database
$database = readJSON(NOTIFICATION_VIEWS_DB);
if ($database === null) {
    $database = ['views' => []];
}

// Check if already marked as read
$alreadyRead = false;
foreach ($database['views'] as $view) {
    if ($view['user_id'] === $user['id'] && $view['notification_id'] === $notificationId) {
        $alreadyRead = true;
        break;
    }
}

if (!$alreadyRead) {
    // Mark as read
    $view = [
        'id' => 'view_' . uniqid('', true),
        'user_id' => $user['id'],
        'notification_id' => $notificationId,
        'viewed_at' => date('Y-m-d H:i:s'),
        'created_at' => date('Y-m-d H:i:s')
    ];

    $database['views'][] = $view;

    // Save to database
    if (writeJSON(NOTIFICATION_VIEWS_DB, $database)) {
        // Log activity
        logActivity($user['id'], 'notification_read', "Read notification: $notificationId");

        sendResponse(true, 'Notification marked as read', ['view' => $view]);
    } else {
        sendResponse(false, 'Failed to mark notification as read', null, 500);
    }
} else {
    sendResponse(true, 'Notification already marked as read');
}
?>
