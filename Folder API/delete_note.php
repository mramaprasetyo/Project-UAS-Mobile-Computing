<?php
header('Content-Type: application/json');
include 'db_connect.php';

$id = $_POST['id'] ?? '';

$stmt = $conn->prepare("UPDATE notes SET is_deleted = 1, updated_at=NOW() WHERE id = ?");
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Catatan berhasil dihapus"]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal menghapus catatan"]);
}
?>
