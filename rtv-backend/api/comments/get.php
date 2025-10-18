<?php
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendResponse(false, 'Method not allowed', null, 405);
}

// Get channel_id from query parameter
$channelId = $_GET['channel_id'] ?? null;

if (!$channelId) {
    sendResponse(false, 'Channel ID is required', null, 400);
}

$database = readJSON(COMMENTS_DB);
if ($database === null) {
    sendResponse(false, 'Database error', null, 500);
}

$allComments = $database['comments'] ?? [];

// Filter comments by channel_id
$comments = array_filter($allComments, function($comment) use ($channelId) {
    return isset($comment['channel_id']) && $comment['channel_id'] === $channelId;
});

// Re-index array
$comments = array_values($comments);

// Sort by timestamp (newest first)
usort($comments, function($a, $b) {
    return $b['timestamp'] - $a['timestamp'];
});

sendResponse(true, 'Comments retrieved successfully', ['comments' => $comments]);
?>
