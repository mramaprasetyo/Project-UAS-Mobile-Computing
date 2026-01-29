import 'package:flutter/material.dart';
import '../services/shared_pref_service.dart';
import 'home_page.dart';
import 'arsip_page.dart';
import 'login_page.dart';
import 'trash_page.dart'; // tambahkan import ini

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int currentIndex = 2; // 0: Arsip, 1: Home, 2: Settings

  void _onNavTapped(int index) {
    if (index == 0 && currentIndex != 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ArsipPage()),
      );
    } else if (index == 1 && currentIndex != 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
    // index == 2 tetap di settings
  }

  void _logout() async {
    await SharedPrefService.clearUser();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEED9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFEED9),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: const Text("Tempat Sampah"),
            subtitle: const Text("Lihat catatan yang dihapus sementara"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrashPage()),
              );
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.orange),
            title: const Text("Logout"),
            onTap: _logout,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onNavTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.archive_outlined),
            label: 'Arsip',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
