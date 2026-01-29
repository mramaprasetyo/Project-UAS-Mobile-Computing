import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/shared_pref_service.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  bool isArchived = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
      print("DEBUG: Image selected: ${image.path}");
    }
  }

  void _removeImage() {
    setState(() => _selectedImage = null);
    print("DEBUG: Image removed");
  }

  void _toggleArchive() => setState(() => isArchived = !isArchived);

  Future<void> _saveNote() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    if (title.isEmpty && content.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Catatan kosong tidak bisa disimpan.")),
      );
      return;
    }

    final userId = await SharedPrefService.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User belum login")),
      );
      return;
    }

    final noteData = {
      'user_id': userId.toString(),
      'title': title,
      'content': content,
      'color': 'white',
      'is_archived': isArchived ? '1' : '0',
    };

    try {
      print("DEBUG: Sending note data: $noteData");
      if (_selectedImage != null) print("DEBUG: Image path: ${_selectedImage!.path}");

      final success = await addNoteToApi(noteData, _selectedImage);

      print("DEBUG: API response: $success");

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isArchived
                ? "Catatan disimpan ke Arsip"
                : "Catatan berhasil disimpan"),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menyimpan catatan")),
        );
      }
    } catch (e) {
      print("DEBUG: Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  // API call debug-friendly
  Future<bool> addNoteToApi(Map<String, dynamic> noteData, File? imageFile) async {
    try {
      var uri = Uri.parse("https://pencarijawabankaisen.my.id/pencari2_rama_api/add_note.php");
      var request = http.MultipartRequest('POST', uri);

      // Tambahkan fields
      noteData.forEach((key, value) {
        request.fields[key] = value;
      });

      // Tambahkan image jika ada
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
        print("DEBUG: Adding image to request: ${imageFile.path}");
      }

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      print("DEBUG: PHP Response: $respStr");

      // Decode response JSON
      final jsonResp = jsonDecode(respStr);

      // Terima boolean true atau int 1 sebagai sukses
      final successValue = jsonResp['success'];
      return successValue == true || successValue == 1;
    } catch (e) {
      print("DEBUG: Exception in addNoteToApi: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF3E0),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Create Note",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: "Add Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _contentCtrl,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: "Write note...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (_selectedImage != null) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleArchive,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isArchived ? Colors.orange : Colors.transparent,
                          border: Border.all(color: Colors.orange, width: 2),
                        ),
                        child: Icon(Icons.archive_outlined,
                            color: isArchived ? Colors.white : Colors.orange),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orange, width: 2),
                        ),
                        child: const Icon(Icons.image_outlined,
                            color: Colors.orange),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _saveNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                  child: const Text("Save Note",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
