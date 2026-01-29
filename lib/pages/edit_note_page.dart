import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/shared_pref_service.dart';

class EditNotePage extends StatefulWidget {
  final Map<String, dynamic> note;
  const EditNotePage({super.key, required this.note});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  bool isArchived = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note['title'] ?? '');
    _contentCtrl = TextEditingController(text: widget.note['content'] ?? '');
    isArchived = widget.note['is_archived'] == '1';
    // Jika note punya image URL, kita biarkan null dulu, nanti bisa ditambahkan saat pick image
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  void _removeImage() {
    setState(() => _selectedImage = null);
  }

  void _toggleArchive() {
    setState(() => isArchived = !isArchived);
  }

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
    if (userId == null) return;

    final noteData = {
      'id': widget.note['id'].toString(),
      'user_id': userId.toString(),
      'title': title,
      'content': content,
      'color': widget.note['color'] ?? 'white',
      'is_archived': isArchived ? '1' : '0',
    };

    setState(() => isSaving = true);

    try {
      final success = await ApiService.updateNote(noteData, _selectedImage);
      setState(() => isSaving = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isArchived
                ? "Catatan disimpan ke Arsip"
                : "Catatan berhasil diperbarui"),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memperbarui catatan")),
        );
      }
    } catch (e) {
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
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
          "Edit Note",
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
              child: TextField(
                controller: _contentCtrl,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: "Write note...",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 14),
                        onPressed: _removeImage,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
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
                          color:
                          isArchived ? Colors.orange : Colors.transparent,
                          border: Border.all(color: Colors.orange, width: 2),
                        ),
                        child: Icon(Icons.archive_outlined,
                            color:
                            isArchived ? Colors.white : Colors.orange),
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
                  onPressed: isSaving ? null : _saveNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                  child: Text(
                    isSaving ? "Saving..." : "Save Note",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
