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

// Get viewing history database
$database = readJSON(VIEWING_HISTORY_DB);
if ($database === null) {
    $database = ['history' => []];
}

// Filter history for this user
$userHistory = array_filter($database['history'], function($item) use ($user) {
    return $item['user_id'] === $user['id'];
});

// Sort by last watched (most recent first)
usort($userHistory, function($a, $b) {
    return strtotime($b['last_watched']) - strtotime($a['last_watched']);
});

// Get query parameters
$limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 50;
$contentType = isset($_GET['content_type']) ? sanitizeInput($_GET['content_type']) : null;

// Filter by content type if specified
if ($contentType) {
    $userHistory = array_filter($userHistory, function($item) use ($contentType) {
        return $item['content_type'] === $contentType;
    });
}

// Limit results
$userHistory = array_slice($userHistory, 0, $limit);

// Re-index array
$userHistory = array_values($userHistory);

sendResponse(true, 'Viewing history retrieved successfully', [
    'history' => $userHistory,
    'count' => count($userHistory)
]);
?>
