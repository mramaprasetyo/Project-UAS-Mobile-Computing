<?php
header('Content-Type: application/json');
include 'db_connect.php';

$id = $_POST['id'] ?? '';

if (!$id) {
    echo json_encode(["success" => false, "message" => "ID catatan tidak ditemukan"]);
    exit;
}

$stmt = $conn->prepare("DELETE FROM notes WHERE id = ?");
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Catatan berhasil dihapus permanen"]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal menghapus catatan secara permanen"]);
}
?>
