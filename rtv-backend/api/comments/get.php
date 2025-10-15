<?php
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendResponse(false, 'Method not allowed', null, 405);
}

$database = readJSON(COMMENTS_DB);
if ($database === null) {
    sendResponse(false, 'Database error', null, 500);
}

$comments = $database['comments'] ?? [];
usort($comments, function($a, $b) {
    return $b['timestamp'] - $a['timestamp'];
});

sendResponse(true, 'Comments retrieved successfully', ['comments' => $comments]);
?>
