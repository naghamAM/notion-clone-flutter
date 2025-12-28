import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/settings/settings.dart';
import 'package:flutter_application_1/welcome/welcome_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'search_notes.dart';
import 'add_note.dart';
import 'note_preview.dart';

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> _notes = [];

  final List<Color> _colors = [
    Color(0xff4a936d),
    Color(0xff5470a4),
    Color(0xffa4526f),
    Color(0xff5c6ab6),
    Color(0xffaf8a56),
    Color(0xffc56969),
  ];

  @override
  void initState() {
    super.initState();
    _fetchNotes();
    _getUser();
  }

  void _fetchNotes() async {
    _firestore.collection('notes').snapshots().listen((snapshot) {
      setState(() {
        _notes = snapshot.docs;

        _notes.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          Timestamp t1 = aData['timestamp'] ?? Timestamp.now();
          Timestamp t2 = bData['timestamp'] ?? Timestamp.now();
          return t2.compareTo(t1);
        });

        _notes.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          return (bData['pinned'] ?? false) ? 1 : -1;
        });
      });
    });
  }

  void _navigateToNotePreview(DocumentSnapshot note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotePreviewScreen(note: note),
      ),
    );
  }

  void _navigateToAddOrEditNote({DocumentSnapshot? note}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(
          note: note,
        ),
      ),
    );
  }

  void _logout() async {
    await GoogleSignIn().signOut();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.signOut();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => WelcomeScreen()),
      (_) => false,
    );
  }

  String username = '';
  String email = '';
  String image = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title:
            Text('Notes', style: TextStyle(fontSize: 28, color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.blue, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SearchNotesScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName:
                  Text(username, style: TextStyle(color: Colors.white)),
              accountEmail:
                  Text(email, style: TextStyle(color: Colors.white70)),
              currentAccountPicture: Image.network(image),
              decoration: BoxDecoration(color: Colors.black),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.white),
              title: Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: _notes.length,
          itemBuilder: (context, index) {
            final note = _notes[index];
            final noteData = note.data() as Map<String, dynamic>;
            final isPinned = noteData['pinned'] ?? false;
            final randomColor = _colors[index % _colors.length];
            return GestureDetector(
              onTap: () => _navigateToNotePreview(note),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: randomColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            noteData['title'] ?? '',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          SizedBox(height: 5),
                          Text(
                            noteData['description'] ?? '',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black87),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5),
                          Text(
                            formatTimestamp(noteData['timestamp']),
                            style:
                                TextStyle(fontSize: 13, color: Colors.black54),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isPinned)
                      Icon(Icons.push_pin, color: Colors.black, size: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => _navigateToAddOrEditNote(),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _getUser() async {
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      username = user?.displayName ?? '';
      email = user?.email ?? '';
      image = user?.photoURL ?? '';
    });
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd hh:mm:ss a')
        .format(dateTime); // Customize format as needed
  }
}
