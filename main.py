from kivymd.app import MDApp
from kivymd.uix.screen import MDScreen
from kivymd.uix.button import MDRaisedButton
from kivymd.uix.textfield import MDTextField
from kivymd.uix.label import MDLabel
from kivymd.uix.list import TwoLineListItem, MDList
from kivymd.uix.scrollview import MDScrollView
from kivymd.uix.dialog import MDDialog
from kivy.uix.boxlayout import BoxLayout
import sqlite3

class NoteInput(BoxLayout):
    pass

class NotesApp(MDApp):
    def build(self):
        self.theme_cls.primary_palette = "Blue"
        self.screen = self.root = MDScreen()
        self.conn = sqlite3.connect("notes.db")
        self.cursor = self.conn.cursor()
        self.cursor.execute('''CREATE TABLE IF NOT EXISTS notes
                               (id INTEGER PRIMARY KEY AUTOINCREMENT,
                                title TEXT,
                                content TEXT)''')
        self.conn.commit()
        return self.screen

    def on_start(self):
        self.refresh_notes()

    def refresh_notes(self):
        note_list = self.root.ids.note_list
        note_list.clear_widgets()
        self.cursor.execute("SELECT id, title, content FROM notes")
        for note in self.cursor.fetchall():
            item = TwoLineListItem(
                text=note[1],
                secondary_text=note[2],
                on_release=lambda x, nid=note[0]: self.delete_note_dialog(nid)
            )
            note_list.add_widget(item)

    def show_add_note_dialog(self):
        self.dialog = MDDialog(
            title="Новая заметка",
            type="custom",
            content_cls=NoteInput(),
            buttons=[
                MDRaisedButton(text="Сохранить", on_release=self.save_note),
                MDRaisedButton(text="Отмена", on_release=lambda x: self.dialog.dismiss())
            ],
        )
        self.dialog.open()

    def save_note(self, *args):
        title = self.dialog.content_cls.ids.title_input.text
        content = self.dialog.content_cls.ids.content_input.text
        if title.strip():
            self.cursor.execute("INSERT INTO notes (title, content) VALUES (?, ?)", (title, content))
            self.conn.commit()
            self.dialog.dismiss()
            self.refresh_notes()

    def delete_note_dialog(self, note_id):
        self.dialog = MDDialog(
            title="Удалить заметку?",
            text="Вы уверены?",
            buttons=[
                MDRaisedButton(text="Да", on_release=lambda x: self.delete_note(note_id)),
                MDRaisedButton(text="Нет", on_release=lambda x: self.dialog.dismiss())
            ],
        )
        self.dialog.open()

    def delete_note(self, note_id):
        self.cursor.execute("DELETE FROM notes WHERE id = ?", (note_id,))
        self.conn.commit()
        self.dialog.dismiss()
        self.refresh_notes()

    def search_notes(self, text):
        self.root.ids.note_list.clear_widgets()
        query = f"%{text}%"
        self.cursor.execute("SELECT id, title, content FROM notes WHERE title LIKE ?", (query,))
        for note in self.cursor.fetchall():
            item = TwoLineListItem(
                text=note[1],
                secondary_text=note[2],
                on_release=lambda x, nid=note[0]: self.delete_note_dialog(nid)
            )
            self.root.ids.note_list.add_widget(item)

NotesApp().run()
