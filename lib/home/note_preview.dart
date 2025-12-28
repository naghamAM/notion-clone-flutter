import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'add_note.dart';

class NotePreviewScreen extends StatelessWidget {
  final DocumentSnapshot note;

  NotePreviewScreen({required this.note});

  void _deleteNote(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Column(
          children: [
            Icon(Icons.info, color: Colors.white, size: 40),
            SizedBox(height: 10),
            Text("Delete Note?",
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('notes')
                  .doc(note.id)
                  .delete();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editNote(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(note: note),
      ),
    );
  }

  void _togglePinNote(BuildContext context) {
    final noteData = note.data() as Map<String, dynamic>;
    bool isPinned = noteData['pinned'] ?? false;
    FirebaseFirestore.instance
        .collection('notes')
        .doc(note.id)
        .update({'pinned': !isPinned});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isPinned ? "Note Unpinned" : "Note Pinned"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteData = note.data() as Map<String, dynamic>;
    bool isPinned = noteData['pinned'] ?? false;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: Colors.white),
            onPressed: () => _togglePinNote(context),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () => _deleteNote(context),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () => _editNote(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              noteData['title'] ?? '',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              noteData['description'] ?? '',
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
