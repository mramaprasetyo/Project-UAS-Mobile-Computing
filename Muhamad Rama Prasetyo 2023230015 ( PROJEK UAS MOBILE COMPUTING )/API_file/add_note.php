<?php
header('Content-Type: application/json');
include 'db_connect.php';

$user_id = $_POST['user_id'] ?? '';
$title = $_POST['title'] ?? '';
$content = $_POST['content'] ?? '';
$color = $_POST['color'] ?? 'white';
$is_archived = $_POST['is_archived'] ?? 0;
$image_url = '';

if (isset($_FILES['image'])) {
    $target_dir = "uploads/note_images/";
    if (!is_dir($target_dir)) mkdir($target_dir, 0777, true);

    $file_name = time() . "_" . basename($_FILES["image"]["name"]);
    $target_file = $target_dir . $file_name;
    $file_type = mime_content_type($_FILES["image"]["tmp_name"]);

    $allowed_types = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (in_array($file_type, $allowed_types)) {
        if (move_uploaded_file($_FILES["image"]["tmp_name"], $target_file)) {
            $image_url = "https://pencarijawabankaisen.my.id/pencari2_rama_api/" . $target_file;
        }
    }
}

$stmt = $conn->prepare("INSERT INTO notes (user_id, title, content, color, image_url, is_archived, created_at) VALUES (?, ?, ?, ?, ?, ?, NOW())");
$stmt->bind_param("issssi", $user_id, $title, $content, $color, $image_url, $is_archived);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Catatan berhasil ditambahkan"]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal menambah catatan"]);
}
?>
