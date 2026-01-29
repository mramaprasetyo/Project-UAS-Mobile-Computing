<?php
header('Content-Type: application/json');
include 'db_connect.php';

$id = $_POST['id'] ?? '';

if (empty($id)) {
    echo json_encode(["success" => false, "message" => "ID tidak ditemukan"]);
    exit;
}

$conn->begin_transaction();

try {
    // Ambil data note
    $res = $conn->query("SELECT * FROM notes WHERE id = $id");
    $note = $res->fetch_assoc();

    if (!$note) throw new Exception("Catatan tidak ditemukan");

    // Update jadi deleted
    $conn->query("UPDATE notes SET is_deleted = 1 WHERE id = $id");

    // Salin ke tabel trash
    $stmt = $conn->prepare("INSERT INTO trash (user_id, note_id, title, content, color, image_url, is_archived) VALUES (?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("iissssi", $note['user_id'], $note['id'], $note['title'], $note['content'], $note['color'], $note['image_url'], $note['is_archived']);
    $stmt->execute();

    $conn->commit();
    echo json_encode(["success" => true, "message" => "Catatan dipindahkan ke trash"]);
} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
