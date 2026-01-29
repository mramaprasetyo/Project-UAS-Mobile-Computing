<?php
$host = "localhost";
$user = "pencari2_rama";
$pass = "J@karta30";
$dbname = "pencari2_rama";

$conn = new mysqli($host, $user, $pass, $dbname);
if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Koneksi database gagal: " . $conn->connect_error]));
}
?>
