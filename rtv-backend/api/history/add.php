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

if (!isset($input['content_id']) || !isset($input['content_type'])) {
    sendResponse(false, 'Content ID and content type are required', null, 400);
}

$contentId = sanitizeInput($input['content_id']);
$contentType = sanitizeInput($input['content_type']); // 'video', 'channel', 'category'
$contentTitle = sanitizeInput($input['content_title'] ?? '');
$thumbnailUrl = sanitizeInput($input['thumbnail_url'] ?? '');
$duration = isset($input['duration']) ? (int)$input['duration'] : 0;
$watchTime = isset($input['watch_time']) ? (int)$input['watch_time'] : 0;

// Get viewing history database
$database = readJSON(VIEWING_HISTORY_DB);
if ($database === null) {
    $database = ['history' => []];
}

// Check if this content is already in history (update if exists)
$historyIndex = -1;
foreach ($database['history'] as $index => $item) {
    if ($item['user_id'] === $user['id'] &&
        $item['content_id'] === $contentId &&
        $item['content_type'] === $contentType) {
        $historyIndex = $index;
        break;
    }
}

$historyItem = [
    'user_id' => $user['id'],
    'content_id' => $contentId,
    'content_type' => $contentType,
    'content_title' => $contentTitle,
    'thumbnail_url' => $thumbnailUrl,
    'duration' => $duration,
    'watch_time' => $watchTime,
    'progress_percentage' => $duration > 0 ? round(($watchTime / $duration) * 100, 2) : 0,
    'last_watched' => date('Y-m-d H:i:s'),
    'updated_at' => date('Y-m-d H:i:s')
];

if ($historyIndex >= 0) {
    // Update existing history item
    $historyItem['id'] = $database['history'][$historyIndex]['id'];
    $historyItem['created_at'] = $database['history'][$historyIndex]['created_at'];
    $historyItem['watch_count'] = ($database['history'][$historyIndex]['watch_count'] ?? 1) + 1;
    $database['history'][$historyIndex] = $historyItem;
} else {
    // Create new history item
    $historyItem['id'] = 'history_' . uniqid('', true);
    $historyItem['created_at'] = date('Y-m-d H:i:s');
    $historyItem['watch_count'] = 1;
    $database['history'][] = $historyItem;
}

// Save to database
if (writeJSON(VIEWING_HISTORY_DB, $database)) {
    // Log activity
    logActivity($user['id'], 'content_viewed', "Watched $contentType: $contentTitle");

    sendResponse(true, 'Viewing history updated', ['history' => $historyItem]);
} else {
    sendResponse(false, 'Failed to update viewing history', null, 500);
}
?>
