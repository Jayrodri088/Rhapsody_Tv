<?php
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendResponse(false, 'Method not allowed', null, 405);
}

// Get user if authenticated (optional for notifications)
$token = getAuthToken();
$user = $token ? verifyToken($token) : null;

$notifications = readJSON(NOTIFICATIONS_DB);

if ($notifications === null) {
    $notifications = ['notifications' => []];
}

// Only return active notifications
$activeNotifications = array_filter(
    $notifications['notifications'] ?? [],
    function($notif) {
        return $notif['is_active'] ?? false;
    }
);

// If user is authenticated, add read status to each notification
if ($user) {
    $viewsDb = readJSON(NOTIFICATION_VIEWS_DB);
    $userViews = [];

    if ($viewsDb !== null) {
        // Get all notification IDs that this user has viewed
        foreach ($viewsDb['views'] as $view) {
            if ($view['user_id'] === $user['id']) {
                $userViews[$view['notification_id']] = $view['viewed_at'];
            }
        }
    }

    // Add is_read status to each notification
    $activeNotifications = array_map(function($notif) use ($userViews) {
        $notif['is_read'] = isset($userViews[$notif['id']]);
        $notif['read_at'] = $userViews[$notif['id']] ?? null;
        return $notif;
    }, $activeNotifications);

    // Get unread count
    $unreadCount = count(array_filter($activeNotifications, function($notif) {
        return !$notif['is_read'];
    }));
}

// Sort by created_at descending
usort($activeNotifications, function($a, $b) {
    return strtotime($b['created_at']) - strtotime($a['created_at']);
});

$responseData = [
    'notifications' => array_values($activeNotifications)
];

if ($user) {
    $responseData['unread_count'] = $unreadCount ?? 0;
}

sendResponse(true, 'Notifications retrieved successfully', $responseData);
?>
