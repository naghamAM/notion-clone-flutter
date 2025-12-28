import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import 'note_preview.dart';

class SearchNotesScreen extends StatefulWidget {
  @override
  _SearchNotesScreenState createState() => _SearchNotesScreenState();
}

class _SearchNotesScreenState extends State<SearchNotesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> _notes = [];
  List<QueryDocumentSnapshot> _filteredNotes = [];
  TextEditingController _searchController = TextEditingController();

  final List<Color> _colors = [
    Color(0xff428864),
    Color(0xff425b88),
    Color(0xff88425b),
    Color(0xff424e88),
    Color(0xff886c42),
    Color(0xff884242),
  ];

  @override
  void initState() {
    super.initState();
    _fetchNotes();
    _searchController.addListener(_filterNotes);
  }

  void _fetchNotes() async {
    _firestore.collection('notes').snapshots().listen((snapshot) {
      setState(() {
        _notes = snapshot.docs;
        _filteredNotes = _notes;
      });
    });
  }

  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes = _notes.where((note) {
        final noteData = note.data() as Map<String, dynamic>;
        final title = noteData['title']?.toLowerCase() ?? '';
        return title.contains(query);
      }).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search by the keyword...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white70),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _filteredNotes.isEmpty
            ? Center(child: Image.asset('assets/search.png'))
            : ListView.builder(
                itemCount: _filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = _filteredNotes[index];
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
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                  maxLines: 1,
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
    );
  }
}
