<?php
header('Content-Type: application/json');
include 'db_connect.php';

$id = $_POST['id'] ?? '';
$is_archived = $_POST['is_archived'] ?? 1;

$stmt = $conn->prepare("UPDATE notes SET is_archived = ?, updated_at=NOW() WHERE id = ?");
$stmt->bind_param("ii", $is_archived, $id);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Status arsip diperbarui"]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal mengarsipkan catatan"]);
}
?>
