<?php
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendResponse(false, 'Method not allowed', null, 405);
}

$categories = readJSON(CATEGORIES_DB);

if ($categories === null) {
    $categories = ['categories' => []];
}

sendResponse(true, 'Categories retrieved successfully', $categories);
?>
