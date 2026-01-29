<?php
header('Content-Type: application/json');
include 'db_connect.php';

$user_id = $_GET['user_id'] ?? '';

if (empty($user_id)) {
    echo json_encode(["success" => false, "message" => "User ID tidak ditemukan"]);
    exit;
}

try {
    $stmt = $conn->prepare("SELECT * FROM trash WHERE user_id = ? ORDER BY deleted_at DESC");
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
    echo json_encode([
        "success" => false,
        "message" => "Gagal memuat trash: " . $e->getMessage()
    ]);
}
?>
