import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddNoteScreen extends StatefulWidget {
  final DocumentSnapshot? note;

  AddNoteScreen({this.note});

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _isEditing = true;
      final noteData = widget.note!.data() as Map<String, dynamic>;
      _titleController.text = noteData['title'] ?? '';
      _descriptionController.text = noteData['description'] ?? '';
    }
  }

  void _saveNote() async {
    if (_titleController.text.isEmpty && _descriptionController.text.isEmpty) return;

    final noteData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    if (_isEditing) {
      await FirebaseFirestore.instance.collection('notes').doc(widget.note!.id).update(noteData);
    } else {
      await FirebaseFirestore.instance.collection('notes').add(noteData);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(color: Colors.white, fontSize: 24),
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 24),
                border: InputBorder.none,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _descriptionController,
                style: TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Type something...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                  border: InputBorder.none,
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}