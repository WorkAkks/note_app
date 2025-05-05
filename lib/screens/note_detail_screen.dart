import 'package:flutter/material.dart';
import '../models/note.dart';
import '../utils/database_helper.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? note;

  NoteDetailScreen({this.note});

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _content;
  late DatabaseHelper dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
    _title = widget.note?.title ?? '';
    _content = widget.note?.content ?? '';
  }

  void saveNote() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final note = Note(
        id: widget.note?.id,
        title: _title,
        content: _content,
        date: DateTime.now().toString(),
      );
      if (widget.note == null) {
        await dbHelper.insertNote(note);
      } else {
        await dbHelper.updateNote(note);
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.note == null ? 'Новая заметка' : 'Редактировать')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Заголовок'),
                onSaved: (value) => _title = value!,
                validator: (value) => value!.isEmpty ? 'Введите заголовок' : null,
              ),
              TextFormField(
                initialValue: _content,
                decoration: InputDecoration(labelText: 'Содержание'),
                onSaved: (value) => _content = value!,
                validator: (value) => value!.isEmpty ? 'Введите содержание' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveNote,
                child: Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
