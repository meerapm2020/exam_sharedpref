import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Todo extends StatefulWidget {
  const Todo({super.key});

  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  List<Map<String, String>> _todoItems = [];

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  _loadTodoItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? titles = prefs.getStringList('titlekey');
    List<String>? contents = prefs.getStringList('contentkey');

    if (titles != null &&
        contents != null &&
        titles.length == contents.length) {
      setState(() {
        _todoItems = List.generate(titles.length, (index) {
          return {
            'titlekey': titles[index],
            'contentkey': contents[index],
          };
        });
      });
    }
  }

  _saveTodoItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> titles = _todoItems.map((item) => item['titlekey']!).toList();
    List<String> contents =
        _todoItems.map((item) => item['contentkey']!).toList();

    await prefs.setStringList('titlekey', titles);
    await prefs.setStringList('contentkey', contents);
  }

  void _addTodoItem(String title, String content) {
    if (title.isNotEmpty && content.isNotEmpty) {
      setState(() {
        _todoItems.add({'titlekey': title, 'contentkey': content});
      });
      _saveTodoItems();
      titleController.clear();
      contentController.clear();
    }
  }

  void _removeTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
    _saveTodoItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo App"),
      ),
      body: ListView.builder(
        itemCount: _todoItems.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: ListTile(
              title: Text(_todoItems[index]['titlekey']!),
              subtitle: Text(_todoItems[index]['contentkey']!),
              trailing: GestureDetector(
                onTap: () {
                  _removeTodoItem(index);
                },
                child: Icon(Icons.delete),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 350,
                  child: Column(
                    children: [
                      Text("Title"),
                      SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        width: 250,
                        child: TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(), labelText: "Title"),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text("Content"),
                      SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        width: 250,
                        child: TextField(
                          controller: contentController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Content"),
                        ),
                      ),
                      SizedBox(height: 35),
                      ElevatedButton(
                          onPressed: () {
                            _addTodoItem(
                                titleController.text, contentController.text);
                            Navigator.pop(context);
                          },
                          child: Text("Add")),
                    ],
                  ),
                );
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
