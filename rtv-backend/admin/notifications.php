<?php
require_once 'auth.php';
requireAuth();
require_once '../api/functions.php';

$message = '';
$messageType = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';

    if ($action === 'add_notification') {
        $notifications = readJSON(NOTIFICATIONS_DB);
        if ($notifications === null) {
            $notifications = ['notifications' => []];
        }
        $newNotification = [
            'id' => 'notif_' . uniqid(),
            'title' => sanitizeInput($_POST['notif_title']),
            'message' => sanitizeInput($_POST['notif_message']),
            'link' => sanitizeInput($_POST['notif_link'] ?? ''),
            'link_text' => sanitizeInput($_POST['notif_link_text'] ?? ''),
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
        foreach ($notifications['notifications'] as &$notification) {
            if ($notification['id'] === $id) {
                $notification['title'] = sanitizeInput($_POST['notif_title']);
                $notification['message'] = sanitizeInput($_POST['notif_message']);
                $notification['link'] = sanitizeInput($_POST['notif_link'] ?? '');
                $notification['link_text'] = sanitizeInput($_POST['notif_link_text'] ?? '');
                $notification['is_active'] = isset($_POST['notif_active']);
                $notification['updated_at'] = date('Y-m-d H:i:s');
                break;
            }
        }
        if (writeJSON(NOTIFICATIONS_DB, $notifications)) {
            $message = 'Notification updated successfully!';
            $messageType = 'success';
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

$notifications = readJSON(NOTIFICATIONS_DB);
if ($notifications === null) {
    $notifications = ['notifications' => []];
}
$allNotifications = $notifications['notifications'] ?? [];

// Load channels for dropdown
$channels = readJSON(CHANNELS_DB);
$allChannels = $channels['channels'] ?? [];

$editingNotification = null;
if (isset($_GET['edit'])) {
    $editNotifId = $_GET['edit'];
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
    <title>Notifications Management - RhapsodyTV Admin</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #EFF0FF; }
        .header { background: linear-gradient(135deg, #0033FF 0%, #0055FF 100%); color: white; padding: 20px 0; box-shadow: 0 4px 20px rgba(0, 51, 255, 0.3); }
        .header-content { max-width: 1400px; margin: 0 auto; padding: 0 20px; display: flex; justify-content: space-between; align-items: center; }
        h1 { font-size: 26px; font-weight: 700; }
        .nav-links { display: flex; gap: 15px; }
        .nav-links a { color: white; text-decoration: none; padding: 8px 16px; border-radius: 6px; background: rgba(255,255,255,0.1); }
        .nav-links a:hover { background: rgba(255,255,255,0.2); }
        .container { max-width: 1400px; margin: 30px auto; padding: 0 20px; }
        .card { background: white; border-radius: 12px; padding: 30px; margin-bottom: 25px; box-shadow: 0 2px 10px rgba(0, 51, 255, 0.08); }
        .card-title { font-size: 20px; font-weight: 700; color: #0033FF; margin-bottom: 25px; padding-bottom: 15px; border-bottom: 2px solid #EFF0FF; display: flex; justify-content: space-between; align-items: center; }
        .form-group { margin-bottom: 20px; }
        label { display: block; font-weight: 600; margin-bottom: 8px; color: #333; font-size: 14px; }
        input[type="text"], input[type="url"], textarea { width: 100%; padding: 12px 16px; border: 2px solid #e5e7eb; border-radius: 8px; font-size: 15px; font-family: inherit; }
        textarea { min-height: 100px; resize: vertical; }
        input:focus, textarea:focus { outline: none; border-color: #0033FF; box-shadow: 0 0 0 3px rgba(0, 51, 255, 0.1); }
        .checkbox-group { display: flex; gap: 25px; margin: 15px 0; }
        .checkbox-group label { display: flex; align-items: center; gap: 8px; font-weight: normal; cursor: pointer; }
        .btn-primary { background: linear-gradient(135deg, #0033FF 0%, #0055FF 100%); color: white; padding: 12px 32px; border: none; border-radius: 8px; font-size: 16px; font-weight: 600; cursor: pointer; }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 10px 20px rgba(0, 51, 255, 0.3); }
        .btn-secondary { background: #6b7280; color: white; padding: 10px 24px; border: none; border-radius: 8px; font-size: 14px; font-weight: 600; text-decoration: none; display: inline-block; }
        .btn-edit { background: #0033FF; color: white; padding: 8px 16px; border: none; border-radius: 6px; font-size: 14px; font-weight: 600; text-decoration: none; display: inline-block; margin-right: 5px; }
        .btn-danger { background: #ef4444; color: white; padding: 8px 16px; border: none; border-radius: 6px; font-size: 14px; font-weight: 600; cursor: pointer; }
        .alert { padding: 16px 20px; border-radius: 8px; margin-bottom: 20px; font-weight: 500; }
        .alert-success { background: #d1fae5; color: #065f46; border: 1px solid #a7f3d0; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 14px 12px; text-align: left; border-bottom: 1px solid #EFF0FF; }
        th { background: #F9FAFB; font-weight: 600; color: #374151; font-size: 13px; text-transform: uppercase; }
        tr:hover { background: #F9FAFB; }
        .badge { display: inline-block; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: 700; text-transform: uppercase; }
        .editing-banner { background: #FEF3C7; border: 2px solid #F59E0B; padding: 15px 20px; border-radius: 8px; margin-bottom: 20px; }
        .editing-banner strong { color: #92400E; }
    </style>
</head>
<body>
    <div class="header">
        <div class="header-content">
            <h1>Notifications Management</h1>
            <div class="nav-links">
                <a href="dashboard.php">← Back to Dashboard</a>
                <a href="?logout=1">Logout</a>
            </div>
        </div>
    </div>

    <div class="container">
        <?php if ($message): ?>
            <div class="alert alert-<?php echo $messageType; ?>">
                <?php echo htmlspecialchars($message); ?>
            </div>
        <?php endif; ?>

        <!-- Add/Edit Notification Form -->
        <div class="card">
            <div class="card-title">
                <span><?php echo $editingNotification ? 'Edit Notification' : 'Add New Notification'; ?></span>
                <?php if ($editingNotification): ?>
                    <a href="notifications.php" class="btn-secondary">Cancel Edit</a>
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
                    <textarea name="notif_message" required placeholder="Enter notification message..."><?php echo $editingNotification ? htmlspecialchars($editingNotification['message']) : ''; ?></textarea>
                </div>

                <div class="form-group">
                    <label>Link (Optional)</label>
                    <input type="url" name="notif_link" placeholder="https://example.com"
                        value="<?php echo $editingNotification ? htmlspecialchars($editingNotification['link'] ?? '') : ''; ?>">
                    <small style="color: #6b7280;">Leave empty if no link needed</small>
                </div>

                <div class="form-group">
                    <label>Link Text (Optional)</label>
                    <input type="text" name="notif_link_text" placeholder="e.g., Learn More, Read Article, Watch Now"
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
                <p style="text-align: center; color: #9ca3af; padding: 40px;">No notifications yet. Add your first notification above!</p>
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
                                    <a href="?edit=<?php echo htmlspecialchars($notification['id']); ?>" class="btn-edit">Edit</a>
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
</body>
</html>
