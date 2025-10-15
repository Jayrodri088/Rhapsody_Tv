<?php
// Shared helper functions without headers
// Safe to include in both API and admin contexts

define('DB_PATH', __DIR__ . '/database/');
define('USERS_DB', DB_PATH . 'users.json');
define('COMMENTS_DB', DB_PATH . 'comments.json');
define('CHANNELS_DB', DB_PATH . 'channels.json');
define('CATEGORIES_DB', DB_PATH . 'categories.json');
define('NOTIFICATIONS_DB', DB_PATH . 'notifications.json');
define('USER_SETTINGS_DB', DB_PATH . 'user_settings.json');
define('NOTIFICATION_VIEWS_DB', DB_PATH . 'notification_views.json');
define('VIEWING_HISTORY_DB', DB_PATH . 'viewing_history.json');
define('ACTIVITY_LOGS_DB', DB_PATH . 'activity_logs.json');

function readJSON($file) {
    if (!file_exists($file)) return null;
    return json_decode(file_get_contents($file), true);
}

function writeJSON($file, $data) {
    return file_put_contents($file, json_encode($data, JSON_PRETTY_PRINT)) !== false;
}

function sendResponse($success, $message, $data = null, $code = 200) {
    http_response_code($code);
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data,
        'timestamp' => time()
    ]);
    exit();
}

function generateToken($length = 32) {
    return bin2hex(random_bytes($length));
}

function validateEmail($email) {
    return filter_var($email, FILTER_VALIDATE_EMAIL);
}

function sanitizeInput($data) {
    return htmlspecialchars(stripslashes(trim($data)));
}

function verifyToken($token) {
    if (empty($token)) {
        return null;
    }

    $database = readJSON(USERS_DB);
    if ($database === null) {
        return null;
    }

    foreach ($database['users'] as $user) {
        if (isset($user['token']) && $user['token'] === $token) {
            return $user;
        }
    }

    return null;
}

function getAuthToken() {
    $headers = getallheaders();
    if (isset($headers['Authorization'])) {
        $auth = $headers['Authorization'];
        if (preg_match('/Bearer\s+(.*)$/i', $auth, $matches)) {
            return $matches[1];
        }
    }
    return null;
}

function logActivity($userId, $activityType, $description, $metadata = []) {
    $database = readJSON(ACTIVITY_LOGS_DB);
    if ($database === null) {
        $database = ['logs' => []];
    }

    $log = [
        'id' => 'log_' . uniqid('', true),
        'user_id' => $userId,
        'activity_type' => $activityType,
        'description' => $description,
        'metadata' => $metadata,
        'ip_address' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
        'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'unknown',
        'created_at' => date('Y-m-d H:i:s')
    ];

    $database['logs'][] = $log;

    // Keep only last 1000 logs per user to prevent file from growing too large
    $userLogs = array_filter($database['logs'], function($item) use ($userId) {
        return $item['user_id'] === $userId;
    });

    if (count($userLogs) > 1000) {
        // Sort by created_at and keep only last 1000
        usort($userLogs, function($a, $b) {
            return strtotime($b['created_at']) - strtotime($a['created_at']);
        });
        $userLogs = array_slice($userLogs, 0, 1000);

        // Update database with trimmed logs
        $otherLogs = array_filter($database['logs'], function($item) use ($userId) {
            return $item['user_id'] !== $userId;
        });
        $database['logs'] = array_merge($otherLogs, $userLogs);
    }

    writeJSON(ACTIVITY_LOGS_DB, $database);
    return $log;
}

function getUserActivityLogs($userId, $limit = 50, $activityType = null) {
    $database = readJSON(ACTIVITY_LOGS_DB);
    if ($database === null) {
        return [];
    }

    // Filter logs for this user
    $userLogs = array_filter($database['logs'], function($item) use ($userId, $activityType) {
        $matchUser = $item['user_id'] === $userId;
        if ($activityType) {
            return $matchUser && $item['activity_type'] === $activityType;
        }
        return $matchUser;
    });

    // Sort by created_at (most recent first)
    usort($userLogs, function($a, $b) {
        return strtotime($b['created_at']) - strtotime($a['created_at']);
    });

    // Limit results
    return array_values(array_slice($userLogs, 0, $limit));
}
?>
