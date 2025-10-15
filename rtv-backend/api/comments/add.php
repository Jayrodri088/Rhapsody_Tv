<?php
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse(false, 'Method not allowed', null, 405);
}

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['user_id']) || !isset($input['comment'])) {
    sendResponse(false, 'User ID and comment are required', null, 400);
}

$userId = sanitizeInput($input['user_id']);
$comment = sanitizeInput($input['comment']);
$username = sanitizeInput($input['username'] ?? 'Anonymous');

if (strlen($comment) < 1 || strlen($comment) > 500) {
    sendResponse(false, 'Comment must be between 1 and 500 characters', null, 400);
}

$database = readJSON(COMMENTS_DB);
if ($database === null) {
    sendResponse(false, 'Database error', null, 500);
}

$newComment = [
    'id' => uniqid('comment_', true),
    'user_id' => $userId,
    'username' => $username,
    'comment' => $comment,
    'created_at' => date('Y-m-d H:i:s'),
    'timestamp' => time()
];

$database['comments'][] = $newComment;

if (writeJSON(COMMENTS_DB, $database)) {
    sendResponse(true, 'Comment added successfully', ['comment' => $newComment], 201);
} else {
    sendResponse(false, 'Failed to save comment', null, 500);
}
?>
