import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/shared_pref_service.dart';
import '../widgets/note_card.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'edit_note_page.dart';

class ArsipPage extends StatefulWidget {
  final VoidCallback? onUnarchive;

  const ArsipPage({super.key, this.onUnarchive});

  @override
  State<ArsipPage> createState() => _ArsipPageState();
}

class _ArsipPageState extends State<ArsipPage> {
  List<Map<String, dynamic>> archivedNotes = [];
  bool isLoading = false;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadArchivedNotes();
  }

  Future<void> _loadArchivedNotes() async {
    try {
      setState(() => isLoading = true);
      final userId = await SharedPrefService.getUserId();
      if (userId == null) throw Exception("User belum login");
      final data = await ApiService.getArchivedNotes(userId);
      setState(() {
        archivedNotes = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal memuat arsip: $e")));
    }
  }

  Future<void> _toggleArchive(Map<String, dynamic> note) async {
    try {
      final noteId = note['id'];
      final success = await ApiService.archiveNote(noteId); // unarchive
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Note dikembalikan ke Home")),
        );
        setState(() {
          archivedNotes.removeWhere((n) => n['id'] == noteId);
        });
        if (widget.onUnarchive != null) widget.onUnarchive!();
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal memindahkan note: $e")));
    }
  }

  Future<void> _moveToTrash(int noteId) async {
    final success = await ApiService.moveToTrash(noteId);
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Note dipindahkan ke Trash")));
      setState(() {
        archivedNotes.removeWhere((n) => n['id'] == noteId);
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Gagal memindahkan note")));
    }
  }

  void _onNavTapped(int index) {
    if (index == 0) {
      // tetap di halaman Arsip
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SettingsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEED9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFEED9),
        centerTitle: true,
        title: const Text(
          "Arsip",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : archivedNotes.isEmpty
          ? const Center(child: Text("Belum ada catatan di arsip"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: archivedNotes.length,
        itemBuilder: (context, index) {
          final note = archivedNotes[index];
          return NoteCard(
            note: note,
            onTap: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditNotePage(note: note),
                ),
              );
              if (updated == true) _loadArchivedNotes();
            },
            onArchive: () => _toggleArchive(note),
            onTrash: () => _moveToTrash(note['id']),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onNavTapped,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.archive_outlined), label: 'Arsip'),
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
