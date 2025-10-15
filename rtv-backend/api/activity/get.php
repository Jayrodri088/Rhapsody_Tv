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

// Get query parameters
$limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 50;
$activityType = isset($_GET['type']) ? sanitizeInput($_GET['type']) : null;

// Get user activity logs
$logs = getUserActivityLogs($user['id'], $limit, $activityType);

sendResponse(true, 'Activity logs retrieved successfully', [
    'logs' => $logs,
    'count' => count($logs)
]);
?>
