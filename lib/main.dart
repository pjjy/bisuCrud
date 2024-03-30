import 'package:flutter/material.dart';
import 'sql_lIte.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CRUD'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future createDatabase() async {
    await sqlLite.init();
  }

  @override
  void initState() {
    fetchUserData();
    createDatabase();
    super.initState();
  }

  final sqlLite = CheckData();
  final TextEditingController _addName = TextEditingController();
  final TextEditingController _editName = TextEditingController();
  List userdata = [];
  Future fetchUserData() async {
    var response = await sqlLite.fetchUsers();
    setState(() {
      userdata = response;
      print(userdata);
    });
  }

  Future<void> _addUserTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add User'),
          content: TextField(
            controller: _addName,
            // decoration: const InputDecoration(hintText: "Text Field in Dialog"),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              onPressed: () {
                sqlLite.addUser(_addName.text);
                fetchUserData();
                _addName.clear();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            )
          ],
        );
      },
    );
  }

  Future<void> _editUserDialog(BuildContext context, name, id) async {
    _editName.text = name;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: TextField(
            controller: _editName,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              onPressed: () {
                sqlLite.updateUser(id, _editName.text);
                fetchUserData();
                _editName.clear();
                Navigator.pop(context);
              },
              child: const Text('Update'),
            )
          ],
        );
      },
    );
  }

  Future<void> _deleteUserDialog(BuildContext context, id) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: const Text("Are you sure you want to delete this user?"),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              onPressed: () {
                sqlLite.deleteUser(id);
                fetchUserData();
                _editName.clear();
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: userdata.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(userdata[index]["name"].toString()),
            trailing: Wrap(
              spacing: 12, // space between two icons
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => {
                    _editUserDialog(
                        context, userdata[index]["name"], userdata[index]["id"])
                  },
                ), // icon-1
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () =>
                      {_deleteUserDialog(context, userdata[index]["id"])},
                ), // icon-2
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addUserTextInputDialog(context);
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
