import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/shared_pref_service.dart';
import '../widgets/note_card.dart';

class TrashPage extends StatefulWidget {
  const TrashPage({super.key});

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  List<Map<String, dynamic>> trashNotes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTrashNotes();
  }

  Future<void> _loadTrashNotes() async {
    try {
      setState(() => isLoading = true);
      final userId = await SharedPrefService.getUserId();
      if (userId == null) throw Exception("User belum login");
      final data = await ApiService.getTrashNotes(userId);
      setState(() {
        trashNotes = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat catatan sampah: $e")),
      );
    }
  }

  Future<void> _restoreNote(Map<String, dynamic> note) async {
    final success = await ApiService.restoreNote(note['id']);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Note berhasil dikembalikan")),
      );
      Navigator.pop(context, true); // pop ke HomePage supaya reload notes
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memulihkan note")),
      );
    }
  }

  Future<void> _deletePermanently(Map<String, dynamic> note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Permanen"),
        content: const Text(
            "Anda yakin ingin menghapus note ini secara permanen?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await ApiService.deleteNoteForever(note['id']);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Note berhasil dihapus permanen")),
      );
      Navigator.pop(context, true); // pop ke HomePage supaya reload notes
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menghapus note")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEED9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFEED9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Tempat Sampah",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trashNotes.isEmpty
          ? const Center(child: Text("Belum ada catatan di tempat sampah"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trashNotes.length,
        itemBuilder: (context, index) {
          final note = trashNotes[index];
          return NoteCard(
            note: note,
            onRestore: () => _restoreNote(note),
            onDelete: () => _deletePermanently(note),
            onTap: null,
          );
        },
      ),
    );
  }
}
