import 'package:flutter/material.dart';
import 'package:simple_note/database_helper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> myData = [];
  bool isLoading = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _refreshData() async {
    try {
      final data = await DatabaseHelper.getItems();
      if (!mounted) return;
      setState(() {
        myData = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading data: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void showMyForm(int? id) async {
    if (id != null) {
      final existingData = myData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'] ?? '';
      _descriptionController.text = existingData['description'] ?? '';
    } else {
      _titleController.clear();
      _descriptionController.clear();
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (id == null) {
                  await addItem();
                } else {
                  await updateItem(id);
                }

                _titleController.clear();
                _descriptionController.clear();

                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                }
              },
              child: Text(id == null ? 'Create New' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addItem() async {
    await DatabaseHelper.createItem(
      _titleController.text,
      _descriptionController.text,
    );
    _refreshData();
  }

  Future<void> updateItem(int id) async {
    await DatabaseHelper.updateItem(
      id,
      _titleController.text,
      _descriptionController.text,
    );
    _refreshData();
  }

  void deleteItem(int id) async {
    await DatabaseHelper.deleteItem(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully deleted a note!'),
        backgroundColor: Colors.green,
      ),
    );
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SQLite CRUD')),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : myData.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada catatan.\nTekan tombol + untuk menambahkan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: myData.length,
                  itemBuilder: (context, index) => Card(
                    color: Colors.orange[200],
                    margin: const EdgeInsets.all(15),
                    child: ListTile(
                      title: Text(myData[index]['title'] ?? ''),
                      subtitle: Text(myData[index]['description'] ?? ''),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => showMyForm(myData[index]['id']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteItem(myData[index]['id']),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showMyForm(null),
      ),
    );
  }
}
