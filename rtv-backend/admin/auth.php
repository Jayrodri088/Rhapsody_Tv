<?php
session_start();

function requireAuth() {
    if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
        header('Location: index.php');
        exit();
    }
}

function logout() {
    session_destroy();
    header('Location: index.php');
    exit();
}

// Handle logout request
if (isset($_GET['logout'])) {
    logout();
}
?>
