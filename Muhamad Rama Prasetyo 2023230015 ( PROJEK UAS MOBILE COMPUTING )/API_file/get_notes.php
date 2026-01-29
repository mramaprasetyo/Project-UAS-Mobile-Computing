<?php
header('Content-Type: application/json');
include 'db_connect.php';

$response = [];

try {
    $user_id = $_GET['user_id'] ?? '';

    if (empty($user_id)) {
        throw new Exception("User ID tidak ditemukan");
    }

    $stmt = $conn->prepare("SELECT * FROM notes WHERE user_id = ? AND is_archived = 0 AND is_deleted = 0 ORDER BY created_at DESC");
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $notes = [];
    while ($row = $result->fetch_assoc()) {
        $notes[] = $row;
    }

    echo json_encode([
        "success" => true,
        "notes" => $notes
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);
}
?>
