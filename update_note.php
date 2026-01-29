<?php
header('Content-Type: application/json');
include 'db_connect.php';

$id = $_POST['id'] ?? '';
$title = $_POST['title'] ?? '';
$content = $_POST['content'] ?? '';
$color = $_POST['color'] ?? '';
$image_url = $_POST['image_url'] ?? '';

$stmt = $conn->prepare("UPDATE notes SET title=?, content=?, color=?, image_url=?, updated_at=NOW() WHERE id=?");
$stmt->bind_param("ssssi", $title, $content, $color, $image_url, $id);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Catatan berhasil diperbarui"]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal memperbarui catatan"]);
}
?>
