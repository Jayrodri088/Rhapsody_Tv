<?php
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendResponse(false, 'Method not allowed', null, 405);
}

$database = readJSON(CHANNELS_DB);
if ($database === null) {
    sendResponse(false, 'Database error', null, 500);
}

$channels = $database['channels'] ?? [];

// Sort by order
usort($channels, function($a, $b) {
    return ($a['order'] ?? 1) - ($b['order'] ?? 1);
});

sendResponse(true, 'Channels retrieved successfully', ['channels' => $channels]);
?>
