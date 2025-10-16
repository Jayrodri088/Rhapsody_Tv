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

// Count items before deletion
$beforeCount = count($database['history']);

// Filter out all history items for this user
$database['history'] = array_filter($database['history'], function($item) use ($user) {
    return $item['user_id'] !== $user['id'];
});

// Re-index array
$database['history'] = array_values($database['history']);

// Count items deleted
$deletedCount = $beforeCount - count($database['history']);

// Save to database
if (writeJSON(VIEWING_HISTORY_DB, $database)) {
    // Log activity
    logActivity($user['id'], 'history_cleared', "Cleared $deletedCount viewing history items");

    sendResponse(true, 'Viewing history cleared successfully', [
        'deleted_count' => $deletedCount
    ]);
} else {
    sendResponse(false, 'Failed to clear viewing history', null, 500);
}
?>
