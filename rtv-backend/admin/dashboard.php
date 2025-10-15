<?php
require_once 'auth.php';
requireAuth();
require_once '../api/functions.php';

// Handle channel operations
$message = '';
$messageType = '';
$debugInfo = ''; // For debugging

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';

    // Debug: Capture POST data for notification actions
    if ($action === 'edit_notification' || $action === 'add_notification') {
        $debugInfo .= "Action: $action | ";
        $debugInfo .= "Link in POST: " . (isset($_POST['notif_link']) ? "YES ('" . $_POST['notif_link'] . "')" : "NO") . " | ";
        $debugInfo .= "Link empty: " . (empty($_POST['notif_link']) ? "YES" : "NO");
    }

    if ($action === 'add_channel') {
        $channels = readJSON(CHANNELS_DB);
        $newChannel = [
            'id' => 'channel_' . uniqid(),
            'name' => sanitizeInput($_POST['name']),
            'stream_url' => sanitizeInput($_POST['stream_url']),
            'thumbnail' => sanitizeInput($_POST['thumbnail']),
            'is_live' => isset($_POST['is_live']),
            'is_featured' => isset($_POST['is_featured']),
            'category' => sanitizeInput($_POST['category'] ?? 'main'),
            'order' => (int)($_POST['order'] ?? 1),
            'created_at' => date('Y-m-d H:i:s')
        ];
        $channels['channels'][] = $newChannel;
        if (writeJSON(CHANNELS_DB, $channels)) {
            $message = 'Channel added successfully!';
            $messageType = 'success';
        }
    } elseif ($action === 'edit_channel') {
        $channels = readJSON(CHANNELS_DB);
        $id = $_POST['id'];
        foreach ($channels['channels'] as &$channel) {
            if ($channel['id'] === $id) {
                $channel['name'] = sanitizeInput($_POST['name']);
                $channel['stream_url'] = sanitizeInput($_POST['stream_url']);
                $channel['thumbnail'] = sanitizeInput($_POST['thumbnail']);
                $channel['is_live'] = isset($_POST['is_live']);
                $channel['is_featured'] = isset($_POST['is_featured']);
                $channel['category'] = sanitizeInput($_POST['category'] ?? 'main');
                $channel['order'] = (int)($_POST['order'] ?? 1);
                $channel['updated_at'] = date('Y-m-d H:i:s');
                break;
            }
        }
        if (writeJSON(CHANNELS_DB, $channels)) {
            $message = 'Channel updated successfully!';
            $messageType = 'success';
        }
    } elseif ($action === 'delete_channel') {
        $channels = readJSON(CHANNELS_DB);
        $id = $_POST['id'];
        $channels['channels'] = array_filter($channels['channels'], function($ch) use ($id) {
            return $ch['id'] !== $id;
        });
        $channels['channels'] = array_values($channels['channels']);
        if (writeJSON(CHANNELS_DB, $channels)) {
            $message = 'Channel deleted successfully!';
            $messageType = 'success';
        }
    } elseif ($action === 'add_category') {
        $categories = readJSON(CATEGORIES_DB);
        if ($categories === null) {
            $categories = ['categories' => []];
        }
        $newCategory = [
            'id' => 'cat_' . uniqid(),
            'name' => sanitizeInput($_POST['cat_name']),
            'slug' => strtolower(str_replace(' ', '_', sanitizeInput($_POST['cat_name']))),
            'icon' => sanitizeInput($_POST['cat_icon'] ?? '📺'),
            'order' => (int)($_POST['cat_order'] ?? 1),
            'created_at' => date('Y-m-d H:i:s')
        ];
        $categories['categories'][] = $newCategory;
        if (writeJSON(CATEGORIES_DB, $categories)) {
            $message = 'Category added successfully!';
            $messageType = 'success';
        }
    } elseif ($action === 'edit_category') {
        $categories = readJSON(CATEGORIES_DB);
        $id = $_POST['cat_id'];
        foreach ($categories['categories'] as &$category) {
            if ($category['id'] === $id) {
                $category['name'] = sanitizeInput($_POST['cat_name']);
                $category['slug'] = strtolower(str_replace(' ', '_', sanitizeInput($_POST['cat_name'])));
                $category['icon'] = sanitizeInput($_POST['cat_icon'] ?? '📺');
                $category['order'] = (int)($_POST['cat_order'] ?? 1);
                $category['updated_at'] = date('Y-m-d H:i:s');
                break;
            }
        }
        if (writeJSON(CATEGORIES_DB, $categories)) {
            $message = 'Category updated successfully!';
            $messageType = 'success';
        }
    } elseif ($action === 'delete_category') {
        $categories = readJSON(CATEGORIES_DB);
        $id = $_POST['cat_id'];
        $categories['categories'] = array_filter($categories['categories'], function($cat) use ($id) {
            return $cat['id'] !== $id;
        });
        $categories['categories'] = array_values($categories['categories']);
        if (writeJSON(CATEGORIES_DB, $categories)) {
            $message = 'Category deleted successfully!';
            $messageType = 'success';
        }
    } elseif ($action === 'add_notification') {
        $notifications = readJSON(NOTIFICATIONS_DB);
        if ($notifications === null) {
            $notifications = ['notifications' => []];
        }
        $linkValue = isset($_POST['notif_link']) ? trim($_POST['notif_link']) : '';
        $linkTextValue = isset($_POST['notif_link_text']) ? trim($_POST['notif_link_text']) : '';
        $newNotification = [
            'id' => 'notif_' . uniqid(),
            'title' => sanitizeInput($_POST['notif_title']),
            'message' => sanitizeInput($_POST['notif_message']),
            'link' => $linkValue, // Store URL as-is, don't use htmlspecialchars
            'link_text' => $linkTextValue,
            'is_active' => isset($_POST['notif_active']),
            'created_at' => date('Y-m-d H:i:s')
        ];
        $notifications['notifications'][] = $newNotification;
        if (writeJSON(NOTIFICATIONS_DB, $notifications)) {
            $message = 'Notification added successfully!';
            $messageType = 'success';
        }
    } elseif ($action === 'edit_notification') {
        $notifications = readJSON(NOTIFICATIONS_DB);
        $id = $_POST['notif_id'];
        $linkValue = isset($_POST['notif_link']) ? trim($_POST['notif_link']) : '';
        $linkTextValue = isset($_POST['notif_link_text']) ? trim($_POST['notif_link_text']) : '';

        $debugInfo .= " | After trim: '$linkValue'";

        $found = false;
        foreach ($notifications['notifications'] as &$notification) {
            if ($notification['id'] === $id) {
                $found = true;
                $notification['title'] = sanitizeInput($_POST['notif_title']);
                $notification['message'] = sanitizeInput($_POST['notif_message']);
                $notification['link'] = $linkValue; // Store URL as-is, don't use htmlspecialchars
                $notification['link_text'] = $linkTextValue;
                $notification['is_active'] = isset($_POST['notif_active']);
                $notification['updated_at'] = date('Y-m-d H:i:s');

                $debugInfo .= " | Found & Updated: YES | Saved link: '" . $notification['link'] . "'";
                break;
            }
        }

        if (!$found) {
            $debugInfo .= " | Found & Updated: NO - ID not found!";
        }

        // Validate the data before writing
        $jsonEncoded = json_encode($notifications, JSON_PRETTY_PRINT);
        if ($jsonEncoded === false) {
            $debugInfo .= " | JSON Encode: FAILED (" . json_last_error_msg() . ")";
            $message = 'Failed to encode notification data!';
            $messageType = 'error';
        } else {
            $writeResult = writeJSON(NOTIFICATIONS_DB, $notifications);
            $debugInfo .= " | Write to DB: " . ($writeResult ? 'SUCCESS' : 'FAILED');

            if ($writeResult) {
                $message = 'Notification updated successfully!';
                $messageType = 'success';
            } else {
                $debugInfo .= " (Check file permissions: " . (is_writable(NOTIFICATIONS_DB) ? 'writable' : 'NOT writable') . ")";
                $message = 'Failed to save notification! File may not be writable.';
                $messageType = 'error';
            }
        }
    } elseif ($action === 'delete_notification') {
        $notifications = readJSON(NOTIFICATIONS_DB);
        $id = $_POST['notif_id'];
        $notifications['notifications'] = array_filter($notifications['notifications'], function($notif) use ($id) {
            return $notif['id'] !== $id;
        });
        $notifications['notifications'] = array_values($notifications['notifications']);
        if (writeJSON(NOTIFICATIONS_DB, $notifications)) {
            $message = 'Notification deleted successfully!';
            $messageType = 'success';
        }
    }
}

// Load channels and categories
$channels = readJSON(CHANNELS_DB);
$allChannels = $channels['channels'] ?? [];

$categories = readJSON(CATEGORIES_DB);
$allCategories = $categories['categories'] ?? [];

// Load notifications
$notifications = readJSON(NOTIFICATIONS_DB);
$allNotifications = $notifications['notifications'] ?? [];

// Get editing channel if edit_id is present
$editingChannel = null;
if (isset($_GET['edit_channel'])) {
    $editId = $_GET['edit_channel'];
    foreach ($allChannels as $channel) {
        if ($channel['id'] === $editId) {
            $editingChannel = $channel;
            break;
        }
    }
}

// Get editing category if edit_cat is present
$editingCategory = null;
if (isset($_GET['edit_cat'])) {
    $editCatId = $_GET['edit_cat'];
    foreach ($allCategories as $category) {
        if ($category['id'] === $editCatId) {
            $editingCategory = $category;
            break;
        }
    }
}

// Get editing notification if edit_notif is present
$editingNotification = null;
if (isset($_GET['edit_notif'])) {
    $editNotifId = $_GET['edit_notif'];
    foreach ($allNotifications as $notification) {
        if ($notification['id'] === $editNotifId) {
            $editingNotification = $notification;
            break;
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RhapsodyTV Admin Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: #EFF0FF;
        }

        .header {
            background: linear-gradient(135deg, #0033FF 0%, #0055FF 100%);
            color: white;
            padding: 20px 0;
            box-shadow: 0 4px 20px rgba(0, 51, 255, 0.3);
        }

        .header-content {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        h1 {
            font-size: 26px;
            font-weight: 700;
            letter-spacing: 0.5px;
        }

        .btn-logout {
            background: rgba(255,255,255,0.2);
            color: white;
            padding: 10px 20px;
            border: 2px solid rgba(255,255,255,0.3);
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s;
            display: inline-block;
        }

        .btn-logout:hover {
            background: rgba(255,255,255,0.3);
            border-color: rgba(255,255,255,0.5);
            transform: translateY(-2px);
        }

        .container {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 20px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0, 51, 255, 0.1);
            border-left: 4px solid #0033FF;
        }

        .stat-card h3 {
            color: #666;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 10px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .stat-card .number {
            color: #0033FF;
            font-size: 32px;
            font-weight: 700;
        }

        .card {
            background: white;
            border-radius: 12px;
            padding: 30px;
            margin-bottom: 25px;
            box-shadow: 0 2px 10px rgba(0, 51, 255, 0.08);
        }

        .card-title {
            font-size: 20px;
            font-weight: 700;
            color: #0033FF;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid #EFF0FF;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .form-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            font-weight: 600;
            margin-bottom: 8px;
            color: #333;
            font-size: 14px;
        }

        input[type="text"],
        input[type="url"],
        input[type="number"],
        select {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 15px;
            transition: all 0.2s;
            font-family: inherit;
        }

        input:focus, select:focus {
            outline: none;
            border-color: #0033FF;
            box-shadow: 0 0 0 3px rgba(0, 51, 255, 0.1);
        }

        .checkbox-group {
            display: flex;
            gap: 25px;
            margin: 15px 0;
        }

        .checkbox-group label {
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: normal;
            cursor: pointer;
        }

        .checkbox-group input[type="checkbox"] {
            width: 18px;
            height: 18px;
            cursor: pointer;
        }

        .btn-primary {
            background: linear-gradient(135deg, #0033FF 0%, #0055FF 100%);
            color: white;
            padding: 12px 32px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(0, 51, 255, 0.3);
        }

        .btn-secondary {
            background: #6b7280;
            color: white;
            padding: 10px 24px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }

        .btn-secondary:hover {
            background: #4b5563;
        }

        .btn-edit {
            background: #0033FF;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.2s;
            text-decoration: none;
            display: inline-block;
            margin-right: 5px;
        }

        .btn-edit:hover {
            background: #0055FF;
        }

        .btn-danger {
            background: #ef4444;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.2s;
        }

        .btn-danger:hover {
            background: #dc2626;
        }

        .alert {
            padding: 16px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-weight: 500;
        }

        .alert-success {
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #a7f3d0;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th, td {
            padding: 14px 12px;
            text-align: left;
            border-bottom: 1px solid #EFF0FF;
        }

        th {
            background: #F9FAFB;
            font-weight: 600;
            color: #374151;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        tr:hover {
            background: #F9FAFB;
        }

        .badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-right: 5px;
        }

        .badge-live {
            background: #10b981;
            color: white;
        }

        .badge-featured {
            background: #FFD700;
            color: #92400e;
        }

        .thumbnail {
            width: 80px;
            height: 45px;
            object-fit: cover;
            border-radius: 6px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #9ca3af;
        }

        .tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 25px;
            border-bottom: 2px solid #EFF0FF;
        }

        .tab {
            padding: 12px 24px;
            background: none;
            border: none;
            color: #6b7280;
            font-weight: 600;
            cursor: pointer;
            border-bottom: 3px solid transparent;
            margin-bottom: -2px;
            transition: all 0.3s;
        }

        .tab.active {
            color: #0033FF;
            border-bottom-color: #0033FF;
        }

        .tab:hover {
            color: #0033FF;
        }

        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
        }

        .editing-banner {
            background: #FEF3C7;
            border: 2px solid #F59E0B;
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .editing-banner strong {
            color: #92400E;
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="header-content">
            <h1>🎬 RhapsodyTV Admin Dashboard</h1>
            <a href="?logout=1" class="btn-logout">Logout</a>
        </div>
    </div>

    <div class="container">
        <?php if ($message): ?>
            <div class="alert alert-<?php echo $messageType; ?>">
                <?php echo htmlspecialchars($message); ?>
            </div>
        <?php endif; ?>
        <?php if ($debugInfo): ?>
            <div class="alert alert-info" style="background: #e0f2fe; border: 2px solid #0284c7; color: #0c4a6e;">
                <strong>DEBUG:</strong> <?php echo htmlspecialchars($debugInfo); ?>
            </div>
        <?php endif; ?>

        <!-- Stats -->
        <div class="stats-grid">
            <div class="stat-card">
                <h3>Total Channels</h3>
                <div class="number"><?php echo count($allChannels); ?></div>
            </div>
            <div class="stat-card">
                <h3>Live Channels</h3>
                <div class="number"><?php echo count(array_filter($allChannels, fn($ch) => $ch['is_live'] ?? false)); ?></div>
            </div>
            <div class="stat-card">
                <h3>Featured Channels</h3>
                <div class="number"><?php echo count(array_filter($allChannels, fn($ch) => $ch['is_featured'] ?? false)); ?></div>
            </div>
            <div class="stat-card">
                <h3>Categories</h3>
                <div class="number"><?php echo count($allCategories); ?></div>
            </div>
            <div class="stat-card">
                <h3>Notifications</h3>
                <div class="number"><?php echo count($allNotifications); ?></div>
            </div>
        </div>

        <!-- Tabs -->
        <div class="tabs">
            <button class="tab active" onclick="switchTab('channels')">Channels</button>
            <button class="tab" onclick="switchTab('categories')">Categories</button>
            <button class="tab" onclick="switchTab('notifications')">Notifications</button>
        </div>

        <!-- Channels Tab -->
        <div class="tab-content active" id="channels-tab">
            <!-- Add/Edit Channel Form -->
            <div class="card">
                <div class="card-title">
                    <span><?php echo $editingChannel ? 'Edit Channel' : 'Add New Channel'; ?></span>
                    <?php if ($editingChannel): ?>
                        <a href="dashboard.php" class="btn-secondary">Cancel Edit</a>
                    <?php endif; ?>
                </div>

                <?php if ($editingChannel): ?>
                    <div class="editing-banner">
                        <strong>Editing: <?php echo htmlspecialchars($editingChannel['name']); ?></strong>
                    </div>
                <?php endif; ?>

                <form method="POST" action="">
                    <input type="hidden" name="action" value="<?php echo $editingChannel ? 'edit_channel' : 'add_channel'; ?>">
                    <?php if ($editingChannel): ?>
                        <input type="hidden" name="id" value="<?php echo htmlspecialchars($editingChannel['id']); ?>">
                    <?php endif; ?>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Channel Name *</label>
                            <input type="text" name="name" required placeholder="e.g., RHAPSODY TV"
                                value="<?php echo $editingChannel ? htmlspecialchars($editingChannel['name']) : ''; ?>">
                        </div>

                        <div class="form-group">
                            <label>Category *</label>
                            <select name="category" required>
                                <option value="main" <?php echo ($editingChannel && ($editingChannel['category'] ?? 'main') === 'main') ? 'selected' : ''; ?>>Main</option>
                                <?php foreach ($allCategories as $cat): ?>
                                    <option value="<?php echo htmlspecialchars($cat['slug']); ?>"
                                        <?php echo ($editingChannel && ($editingChannel['category'] ?? '') === $cat['slug']) ? 'selected' : ''; ?>>
                                        <?php echo htmlspecialchars($cat['name']); ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Display Order</label>
                            <input type="number" name="order" value="<?php echo $editingChannel ? ($editingChannel['order'] ?? 1) : 1; ?>" min="1">
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Stream URL *</label>
                        <input type="url" name="stream_url" required placeholder="https://example.com/stream.m3u8"
                            value="<?php echo $editingChannel ? htmlspecialchars($editingChannel['stream_url']) : ''; ?>">
                    </div>

                    <div class="form-group">
                        <label>Thumbnail URL</label>
                        <input type="url" name="thumbnail" placeholder="https://example.com/thumbnail.jpg"
                            value="<?php echo $editingChannel ? htmlspecialchars($editingChannel['thumbnail'] ?? '') : ''; ?>">
                    </div>

                    <div class="checkbox-group">
                        <label>
                            <input type="checkbox" name="is_live" <?php echo ($editingChannel && ($editingChannel['is_live'] ?? false)) || !$editingChannel ? 'checked' : ''; ?>>
                            Live Channel
                        </label>
                        <label>
                            <input type="checkbox" name="is_featured" <?php echo ($editingChannel && ($editingChannel['is_featured'] ?? false)) || !$editingChannel ? 'checked' : ''; ?>>
                            Featured
                        </label>
                    </div>

                    <button type="submit" class="btn-primary">
                        <?php echo $editingChannel ? 'Update Channel' : 'Add Channel'; ?>
                    </button>
                </form>
            </div>

            <!-- Channels List -->
            <div class="card">
                <div class="card-title">Manage Channels (<?php echo count($allChannels); ?> total)</div>

                <?php if (empty($allChannels)): ?>
                    <div class="empty-state">
                        <p style="font-size: 18px; margin-bottom: 8px;">No channels yet</p>
                        <p>Add your first channel using the form above!</p>
                    </div>
                <?php else: ?>
                    <table>
                        <thead>
                            <tr>
                                <th>Thumbnail</th>
                                <th>Channel Name</th>
                                <th>Category</th>
                                <th>Status</th>
                                <th>Order</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($allChannels as $channel): ?>
                                <tr>
                                    <td>
                                        <?php if (!empty($channel['thumbnail'])): ?>
                                            <img src="<?php echo htmlspecialchars($channel['thumbnail']); ?>" class="thumbnail" alt="<?php echo htmlspecialchars($channel['name']); ?>">
                                        <?php else: ?>
                                            <div style="width:80px;height:45px;background:#e5e7eb;border-radius:6px;"></div>
                                        <?php endif; ?>
                                    </td>
                                    <td>
                                        <strong><?php echo htmlspecialchars($channel['name']); ?></strong>
                                    </td>
                                    <td>
                                        <?php echo htmlspecialchars($channel['category'] ?? 'main'); ?>
                                    </td>
                                    <td>
                                        <?php if ($channel['is_live'] ?? false): ?>
                                            <span class="badge badge-live">Live</span>
                                        <?php endif; ?>
                                        <?php if ($channel['is_featured'] ?? false): ?>
                                            <span class="badge badge-featured">Featured</span>
                                        <?php endif; ?>
                                    </td>
                                    <td>
                                        <?php echo $channel['order'] ?? 1; ?>
                                    </td>
                                    <td>
                                        <a href="?edit_channel=<?php echo htmlspecialchars($channel['id']); ?>" class="btn-edit">Edit</a>
                                        <form method="POST" action="" style="display:inline;" onsubmit="return confirm('Are you sure you want to delete this channel?');">
                                            <input type="hidden" name="action" value="delete_channel">
                                            <input type="hidden" name="id" value="<?php echo htmlspecialchars($channel['id']); ?>">
                                            <button type="submit" class="btn-danger">Delete</button>
                                        </form>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                <?php endif; ?>
            </div>
        </div>

        <!-- Categories Tab -->
        <div class="tab-content" id="categories-tab">
            <!-- Add/Edit Category Form -->
            <div class="card">
                <div class="card-title">
                    <span><?php echo $editingCategory ? 'Edit Category' : 'Add New Category'; ?></span>
                    <?php if ($editingCategory): ?>
                        <a href="dashboard.php" class="btn-secondary">Cancel Edit</a>
                    <?php endif; ?>
                </div>

                <?php if ($editingCategory): ?>
                    <div class="editing-banner">
                        <strong>Editing: <?php echo htmlspecialchars($editingCategory['name']); ?></strong>
                    </div>
                <?php endif; ?>

                <form method="POST" action="">
                    <input type="hidden" name="action" value="<?php echo $editingCategory ? 'edit_category' : 'add_category'; ?>">
                    <?php if ($editingCategory): ?>
                        <input type="hidden" name="cat_id" value="<?php echo htmlspecialchars($editingCategory['id']); ?>">
                    <?php endif; ?>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Category Name *</label>
                            <input type="text" name="cat_name" required placeholder="e.g., Sports"
                                value="<?php echo $editingCategory ? htmlspecialchars($editingCategory['name']) : ''; ?>">
                        </div>

                        <div class="form-group">
                            <label>Icon (Emoji)</label>
                            <input type="text" name="cat_icon" placeholder="📺" maxlength="2"
                                value="<?php echo $editingCategory ? htmlspecialchars($editingCategory['icon'] ?? '📺') : '📺'; ?>">
                        </div>

                        <div class="form-group">
                            <label>Display Order</label>
                            <input type="number" name="cat_order" value="<?php echo $editingCategory ? ($editingCategory['order'] ?? 1) : 1; ?>" min="1">
                        </div>
                    </div>

                    <button type="submit" class="btn-primary">
                        <?php echo $editingCategory ? 'Update Category' : 'Add Category'; ?>
                    </button>
                </form>
            </div>

            <!-- Categories List -->
            <div class="card">
                <div class="card-title">Manage Categories (<?php echo count($allCategories); ?> total)</div>

                <?php if (empty($allCategories)): ?>
                    <div class="empty-state">
                        <p style="font-size: 18px; margin-bottom: 8px;">No categories yet</p>
                        <p>Add your first category using the form above!</p>
                    </div>
                <?php else: ?>
                    <table>
                        <thead>
                            <tr>
                                <th>Icon</th>
                                <th>Category Name</th>
                                <th>Slug</th>
                                <th>Order</th>
                                <th>Channels</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($allCategories as $category): ?>
                                <tr>
                                    <td style="font-size: 24px;">
                                        <?php echo htmlspecialchars($category['icon'] ?? '📺'); ?>
                                    </td>
                                    <td>
                                        <strong><?php echo htmlspecialchars($category['name']); ?></strong>
                                    </td>
                                    <td>
                                        <code style="background: #f3f4f6; padding: 4px 8px; border-radius: 4px;">
                                            <?php echo htmlspecialchars($category['slug']); ?>
                                        </code>
                                    </td>
                                    <td>
                                        <?php echo $category['order'] ?? 1; ?>
                                    </td>
                                    <td>
                                        <?php
                                        $categorySlug = $category['slug'];
                                        $channelCount = count(array_filter($allChannels, fn($ch) => ($ch['category'] ?? 'main') === $categorySlug));
                                        echo $channelCount;
                                        ?>
                                    </td>
                                    <td>
                                        <a href="?edit_cat=<?php echo htmlspecialchars($category['id']); ?>" class="btn-edit">Edit</a>
                                        <form method="POST" action="" style="display:inline;" onsubmit="return confirm('Are you sure you want to delete this category?');">
                                            <input type="hidden" name="action" value="delete_category">
                                            <input type="hidden" name="cat_id" value="<?php echo htmlspecialchars($category['id']); ?>">
                                            <button type="submit" class="btn-danger">Delete</button>
                                        </form>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                <?php endif; ?>
            </div>
        </div>
    </div>


        <!-- Notifications Tab -->
        <div class="tab-content" id="notifications-tab">
            <!-- Add/Edit Notification Form -->
            <div class="card">
                <div class="card-title">
                    <span><?php echo $editingNotification ? 'Edit Notification' : 'Add New Notification'; ?></span>
                    <?php if ($editingNotification): ?>
                        <a href="dashboard.php" class="btn-secondary">Cancel Edit</a>
                    <?php endif; ?>
                </div>

                <?php if ($editingNotification): ?>
                    <div class="editing-banner">
                        <strong>Editing: <?php echo htmlspecialchars($editingNotification['title']); ?></strong>
                    </div>
                <?php endif; ?>

                <form method="POST" action="">
                    <input type="hidden" name="action" value="<?php echo $editingNotification ? 'edit_notification' : 'add_notification'; ?>">
                    <?php if ($editingNotification): ?>
                        <input type="hidden" name="notif_id" value="<?php echo htmlspecialchars($editingNotification['id']); ?>">
                    <?php endif; ?>

                    <div class="form-group">
                        <label>Notification Title *</label>
                        <input type="text" name="notif_title" required placeholder="e.g., New Feature Available"
                            value="<?php echo $editingNotification ? htmlspecialchars($editingNotification['title']) : ''; ?>">
                    </div>

                    <div class="form-group">
                        <label>Message *</label>
                        <textarea name="notif_message" required placeholder="Enter notification message..." rows="4"
                            style="width: 100%; padding: 12px 16px; border: 2px solid #e5e7eb; border-radius: 8px; font-size: 15px; font-family: inherit;"><?php echo $editingNotification ? htmlspecialchars($editingNotification['message']) : ''; ?></textarea>
                    </div>

                    <div class="form-group">
                        <label>Link (Optional)</label>
                        <input type="text" name="notif_link" placeholder="https://example.com" autocomplete="off"
                            value="<?php echo $editingNotification ? htmlspecialchars($editingNotification['link'] ?? '') : ''; ?>">
                        <small style="color: #6b7280;">Leave empty if no link needed. Enter full URL like https://example.com</small>
                    </div>

                    <div class="form-group">
                        <label>Link Text (Optional)</label>
                        <input type="text" name="notif_link_text" placeholder="e.g., Learn More, Read Article, Watch Now" autocomplete="off"
                            value="<?php echo $editingNotification ? htmlspecialchars($editingNotification['link_text'] ?? '') : ''; ?>">
                        <small style="color: #6b7280;">Display text for the link. If empty, the URL will be shown</small>
                    </div>

                    <div class="checkbox-group">
                        <label>
                            <input type="checkbox" name="notif_active" <?php echo ($editingNotification && ($editingNotification['is_active'] ?? false)) || !$editingNotification ? 'checked' : ''; ?>>
                            Active (visible in app)
                        </label>
                    </div>

                    <button type="submit" class="btn-primary">
                        <?php echo $editingNotification ? 'Update Notification' : 'Add Notification'; ?>
                    </button>
                </form>
            </div>

            <!-- Notifications List -->
            <div class="card">
                <div class="card-title">All Notifications (<?php echo count($allNotifications); ?> total)</div>

                <?php if (empty($allNotifications)): ?>
                    <div class="empty-state">
                        <p style="font-size: 18px; margin-bottom: 8px;">No notifications yet</p>
                        <p>Add your first notification using the form above!</p>
                    </div>
                <?php else: ?>
                    <table>
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Message</th>
                                <th>Link</th>
                                <th>Status</th>
                                <th>Created</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($allNotifications as $notification): ?>
                                <tr style="<?php echo !($notification['is_active'] ?? false) ? 'opacity: 0.5;' : ''; ?>">
                                    <td><strong><?php echo htmlspecialchars($notification['title']); ?></strong></td>
                                    <td><small><?php echo htmlspecialchars(substr($notification['message'], 0, 60)) . (strlen($notification['message']) > 60 ? '...' : ''); ?></small></td>
                                    <td>
                                        <?php if (!empty($notification['link'])): ?>
                                            <a href="<?php echo htmlspecialchars($notification['link']); ?>" target="_blank" style="color: #0033FF;"><small>View</small></a>
                                        <?php else: ?>
                                            <small style="color: #9ca3af;">No link</small>
                                        <?php endif; ?>
                                    </td>
                                    <td>
                                        <span class="badge" style="background: <?php echo ($notification['is_active'] ?? false) ? '#10b981' : '#6b7280'; ?>; color: white;">
                                            <?php echo ($notification['is_active'] ?? false) ? 'Active' : 'Inactive'; ?>
                                        </span>
                                    </td>
                                    <td><small><?php echo date('M d, Y', strtotime($notification['created_at'])); ?></small></td>
                                    <td>
                                        <a href="?edit_notif=<?php echo htmlspecialchars($notification['id']); ?>" class="btn-edit">Edit</a>
                                        <form method="POST" style="display:inline;" onsubmit="return confirm('Delete this notification?');">
                                            <input type="hidden" name="action" value="delete_notification">
                                            <input type="hidden" name="notif_id" value="<?php echo htmlspecialchars($notification['id']); ?>">
                                            <button type="submit" class="btn-danger">Delete</button>
                                        </form>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                <?php endif; ?>
            </div>
        </div>
    <script>
        function switchTab(tabName) {
            // Hide all tabs
            document.querySelectorAll('.tab-content').forEach(content => {
                content.classList.remove('active');
            });
            document.querySelectorAll('.tab').forEach(tab => {
                tab.classList.remove('active');
            });

            // Show selected tab
            document.getElementById(tabName + '-tab').classList.add('active');
            event.target.classList.add('active');
        }

        // If editing category, switch to categories tab
        <?php if ($editingCategory): ?>
            document.addEventListener('DOMContentLoaded', function() {
                document.querySelector('.tab:nth-child(2)').click();
            });
        <?php endif; ?>

        // If editing notification, switch to notifications tab
        <?php if ($editingNotification): ?>
            document.addEventListener('DOMContentLoaded', function() {
                document.querySelector('.tab:nth-child(3)').click();
            });
        <?php endif; ?>
    </script>
</body>
</html>
