import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/shared_pref_service.dart';
import '../widgets/note_card.dart';
import 'add_note_page.dart';
import 'edit_note_page.dart';
import 'arsip_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> allNotes = [];
  List<Map<String, dynamic>> filteredNotes = [];
  bool isLoading = true;
  int currentIndex = 1;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchCtrl.addListener(_searchNotes);
  }

  Future<void> _loadNotes() async {
    setState(() => isLoading = true);
    try {
      final userId = await SharedPrefService.getUserId();
      if (userId == null) throw Exception("User belum login");
      final data = await ApiService.getNotes(userId);
      setState(() {
        allNotes = data;
        filteredNotes = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal memuat catatan: $e")));
    }
  }

  void _searchNotes() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      filteredNotes = allNotes.where((note) {
        final title = note['title']?.toLowerCase() ?? '';
        final content = note['content']?.toLowerCase() ?? '';
        return title.contains(query) || content.contains(query);
      }).toList();
    });
  }

  Future<void> _moveToTrash(int noteId) async {
    final success = await ApiService.moveToTrash(noteId);
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Note dipindahkan ke Trash")));
      _loadNotes();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Gagal memindahkan note")));
    }
  }

  void _onNavTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ArsipPage(onUnarchive: _loadNotes),
        ),
      );
    } else if (index == 1) {
      // tetap di homepage
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SettingsPage()),
      );
    }
  }

  void _openAddNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddNotePage()),
    );
    if (result == true) _loadNotes();
  }

  void _openEditNote(Map<String, dynamic> note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditNotePage(note: note)),
    );
    if (result == true) _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEED9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFEED9),
        toolbarHeight: 100, // tinggi untuk judul + search
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Note App",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.orange),
                ),
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredNotes.isEmpty
          ? const Center(child: Text("Belum ada catatan"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) {
          final note = filteredNotes[index];
          return NoteCard(
            note: note,
            onTap: () => _openEditNote(note),
            onTrash: () => _moveToTrash(note['id']),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddNote,
        backgroundColor: Colors.white, // putih
        child: const Icon(Icons.add, color: Colors.orange), // ikon oranye
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
