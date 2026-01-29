import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // 🖥️ Ganti base URL sesuai domain hosting kamu
  static const String baseUrl =
      "https://pencarijawabankaisen.my.id/pencari2_rama_api";

  /// ============================================================
  /// 🔹 REGISTER USER
  /// ============================================================
  static Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final url = Uri.parse("$baseUrl/register.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'username': username, 'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Gagal menghubungi server register.php (${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Kesalahan koneksi register.php: $e");
    }
  }

  /// ============================================================
  /// 🔹 LOGIN USER
  /// ============================================================
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final url = Uri.parse("$baseUrl/login.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Gagal menghubungi server login.php (${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Kesalahan koneksi login.php: $e");
    }
  }

  /// ============================================================
  /// 🔹 AMBIL CATATAN AKTIF
  /// ============================================================
  static Future<List<Map<String, dynamic>>> getNotes(int userId) async {
    final url = Uri.parse("$baseUrl/get_notes.php?user_id=$userId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['notes'] ?? []);
      } else {
        throw Exception("Status ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Gagal memuat catatan: $e");
    }
  }

  /// ============================================================
  /// 🔹 TAMBAH CATATAN (DENGAN GAMBAR & ARSIP)
  /// ============================================================
  static Future<bool> addNote(
      Map<String, dynamic> noteData, File? imageFile) async {
    final url = Uri.parse("$baseUrl/add_note.php");
    var request = http.MultipartRequest('POST', url);

    noteData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['success'] == true) {
        return true;
      } else {
        throw Exception(data['message'] ?? "Gagal menambah catatan");
      }
    } catch (e) {
      throw Exception("Gagal menambah catatan: $e");
    }
  }

  /// ============================================================
  /// 🔹 UPDATE CATATAN DENGAN GAMBAR OPSIONAL
  /// ============================================================
  static Future<bool> updateNote(
      Map<String, dynamic> noteData, File? imageFile) async {
    final url = Uri.parse("$baseUrl/update_note.php");
    var request = http.MultipartRequest('POST', url);

    noteData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['success'] == true) {
        return true;
      } else {
        throw Exception(data['message'] ?? "Gagal memperbarui catatan");
      }
    } catch (e) {
      throw Exception("Gagal memperbarui catatan: $e");
    }
  }


  /// ============================================================
  /// 🔹 ARSIPKAN CATATAN
  /// ============================================================
  static Future<bool> archiveNote(int noteId) async {
    final url = Uri.parse("$baseUrl/archive_note.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'id': noteId.toString()},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        throw Exception("Status ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Gagal mengarsipkan catatan: $e");
    }
  }

  /// ============================================================
  /// 🔹 AMBIL CATATAN ARSIP
  /// ============================================================
  static Future<List<Map<String, dynamic>>> getArchivedNotes(
      int userId) async {
    final url = Uri.parse("$baseUrl/get_archived_notes.php?user_id=$userId");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['notes'] ?? []);
      } else {
        throw Exception("Status ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Gagal memuat arsip: $e");
    }
  }

  /// ============================================================
  /// 🔹 PINDAHKAN KE TRASH
  /// ============================================================
  static Future<bool> moveToTrash(int noteId) async {
    final url = Uri.parse("$baseUrl/move_to_trash.php");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'id': noteId.toString()},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        throw Exception("Status ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Gagal memindahkan ke trash: $e");
    }
  }

  /// ============================================================
  /// 🔹 AMBIL CATATAN DARI TRASH
  /// ============================================================
  static Future<List<Map<String, dynamic>>> getTrashNotes(int userId) async {
    final url = Uri.parse("$baseUrl/get_trash_notes.php?user_id=$userId");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['notes'] ?? []);
      } else {
        throw Exception("Status ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Gagal memuat catatan trash: $e");
    }
  }

  /// ============================================================
  /// 🔹 HAPUS PERMANEN CATATAN DARI TRASH
  /// ============================================================
  static Future<bool> deleteNoteForever(int noteId) async {
    final url = Uri.parse("$baseUrl/delete_note_forever.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'id': noteId.toString()},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        throw Exception("Status ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Gagal menghapus permanen: $e");
    }
  }

  /// ============================================================
  /// 🔹 PULIHKAN CATATAN DARI TRASH
  /// ============================================================
  static Future<bool> restoreNote(int noteId) async {
    final url = Uri.parse("$baseUrl/restore_note.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'id': noteId.toString()},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        throw Exception("Status ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Gagal memulihkan catatan: $e");
    }
  }
}
