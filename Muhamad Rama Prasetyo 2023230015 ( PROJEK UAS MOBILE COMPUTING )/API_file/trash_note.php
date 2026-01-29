<?php
header('Content-Type: application/json');
include 'db_connect.php';

$id = $_POST['id'] ?? '';
$is_trashed = $_POST['is_trashed'] ?? 1;

$stmt = $conn->prepare("UPDATE notes SET is_trashed = ?, updated_at=NOW() WHERE id = ?");
$stmt->bind_param("ii", $is_trashed, $id);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Catatan dipindahkan ke sampah"]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal memindahkan catatan"]);
}
?>
