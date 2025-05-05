import 'package:flutter/material.dart';
import 'screens/note_list_screen.dart';

void main() {
  runApp(NoteKeeperApp());
}

class NoteKeeperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note Keeper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NoteListScreen(),
    );
  }
}
