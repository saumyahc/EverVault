import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MyDiaryScreen extends StatefulWidget {
  const MyDiaryScreen({super.key});

  @override
  _MyDiaryScreenState createState() => _MyDiaryScreenState();
}

class _MyDiaryScreenState extends State<MyDiaryScreen> {
  List<Map<String, String>> diaryEntries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  // Load saved diary entries from local storage
  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedEntries = prefs.getString('diary_entries');
    if (savedEntries != null) {
      setState(() {
        diaryEntries = List<Map<String, String>>.from(json.decode(savedEntries));
      });
    }
  }

  // Save diary entries to local storage
  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('diary_entries', json.encode(diaryEntries));
  }

  // Open a dialog to add a new entry
  void _addNewEntry() {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text("New Diary Entry", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Title", labelStyle: TextStyle(color: Colors.white70)),
              ),
              TextField(
                controller: contentController,
                style: const TextStyle(color: Colors.white),
                maxLines: 5,
                decoration: const InputDecoration(labelText: "Content", labelStyle: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  setState(() {
                    diaryEntries.add({
                      "title": titleController.text,
                      "date": DateTime.now().toLocal().toString().split(' ')[0],
                      "content": contentController.text
                    });
                    _saveEntries();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.greenAccent)),
            ),
          ],
        );
      },
    );
  }

  // Show full diary entry
  void _viewEntry(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(diaryEntries[index]["title"]!, style: const TextStyle(color: Colors.white)),
          content: Text(diaryEntries[index]["content"]!, style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Diary", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade900, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: diaryEntries.isEmpty
            ? const Center(
                child: Text("No diary entries yet!", style: TextStyle(color: Colors.white70, fontSize: 16)),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: diaryEntries.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.black54,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text(diaryEntries[index]["title"]!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        "${diaryEntries[index]["date"]!}  •  ${diaryEntries[index]["content"]!}",
                        style: const TextStyle(color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _viewEntry(index),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: _addNewEntry,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
