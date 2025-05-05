import 'package:flutter/material.dart';
import '../models/note.dart';
import '../utils/database_helper.dart';
import 'note_detail_screen.dart';

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Note> noteList = [];
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    updateListView();
  }

  void updateListView() async {
    final notes = await dbHelper.getNoteList();
    setState(() {
      noteList = notes;
    });
  }

  void navigateToDetail(Note? note) async {
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(note: note),
      ),
    );
    if (result == true) updateListView();
  }

  void deleteNote(Note note) async {
    await dbHelper.deleteNote(note.id!);
    updateListView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Заметки')),
      body: ListView.builder(
        itemCount: noteList.length,
        itemBuilder: (context, index) {
          final note = noteList[index];
          return ListTile(
            title: Text(note.title),
            subtitle: Text(note.date),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => deleteNote(note),
            ),
            onTap: () => navigateToDetail(note),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => navigateToDetail(null),
      ),
    );
  }
}
