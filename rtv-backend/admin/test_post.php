<?php
// Simple test to see what's being posted
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    echo "<h2>POST Data Received:</h2>";
    echo "<pre>";
    print_r($_POST);
    echo "</pre>";

    echo "<h2>Specific Fields:</h2>";
    echo "notif_link isset: " . (isset($_POST['notif_link']) ? 'YES' : 'NO') . "<br>";
    echo "notif_link value: " . var_export($_POST['notif_link'] ?? 'NOT SET', true) . "<br>";
    echo "notif_link after trim: " . var_export(isset($_POST['notif_link']) ? trim($_POST['notif_link']) : 'NOT SET', true) . "<br>";
    exit;
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Test POST</title>
</head>
<body>
    <h1>Test Form Submission</h1>
    <form method="POST" action="">
        <label>Title:</label><br>
        <input type="text" name="notif_title" value="Test Title"><br><br>

        <label>Message:</label><br>
        <textarea name="notif_message">Test Message</textarea><br><br>

        <label>Link:</label><br>
        <input type="text" name="notif_link" value="https://example.com"><br><br>

        <input type="checkbox" name="notif_active" checked> Active<br><br>

        <button type="submit">Submit</button>
    </form>
</body>
</html>
