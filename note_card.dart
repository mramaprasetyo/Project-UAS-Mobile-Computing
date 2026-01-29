import 'package:flutter/material.dart';

class NoteCard extends StatelessWidget {
  final Map<String, dynamic> note;
  final VoidCallback? onTap;
  final VoidCallback? onTrash;
  final VoidCallback? onArchive;
  final VoidCallback? onRestore;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onTrash,
    this.onArchive,
    this.onRestore,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: note['color'] == null ? Colors.white : _getColor(note['color']),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Text(
                note['title'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(note['content'] ?? ''),
            if (note['image_url'] != null && note['image_url'] != '')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.network(
                  note['image_url'],
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onRestore != null)
                  IconButton(
                    icon: const Icon(Icons.restore, color: Colors.green),
                    onPressed: onRestore,
                    tooltip: "Restore",
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: "Hapus Permanen",
                  ),
                if (onTrash != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onTrash,
                    tooltip: "Trash",
                  ),
                if (onArchive != null)
                  IconButton(
                    icon: const Icon(Icons.archive, color: Colors.orange),
                    onPressed: onArchive,
                    tooltip: "Archive",
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(String color) {
    switch (color) {
      case 'white':
        return Colors.white;
      case 'yellow':
        return Colors.yellow.shade100;
      case 'blue':
        return Colors.blue.shade100;
      case 'green':
        return Colors.green.shade100;
      case 'pink':
        return Colors.pink.shade100;
      default:
        return Colors.white;
    }
  }
}
