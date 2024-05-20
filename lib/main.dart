import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solihiyn Zikrs',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 38, 149, 190)),
        useMaterial3: true,
      ),
      home: const ZikrList(),
    );
  }
}

class ZikrList extends StatefulWidget {
  const ZikrList({super.key});

  @override
  _ZikrListState createState() => _ZikrListState();
}

class _ZikrListState extends State<ZikrList> {
  List<Zikr> zikrs = [];

  @override
  void initState() {
    super.initState();
    loadZikrs();
  }

  // File handling methods
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/zikrs.json');
  }

  Future<void> loadZikrs() async {
    try {
      final file = await _localFile;
      // Read the file
      final contents = await file.readAsString();
      final jsonResponse = jsonDecode(contents) as List;
      setState(() {
        zikrs = jsonResponse.map((data) => Zikr.fromJson(data)).toList();
      });
    } catch (e) {
      setState(() {
        zikrs = [];
      });
    }
  }

  Future<File> saveZikrs() async {
    final file = await _localFile;
    // Convert Zikrs to a JSON string and write to the file
    return file
        .writeAsString(jsonEncode(zikrs.map((zikr) => zikr.toJson()).toList()));
  }

  // Update, Delete and Add methods need to invoke saveZikrs
  Future<void> addZikrLocally(Zikr zikr) async {
    setState(() {
      zikrs.add(zikr);
    });
    await saveZikrs();
  }

  Future<void> updateZikr(int index, String newTitle, int newCount, int newLimit, String newCategory) async {
    setState(() {
      zikrs[index].title = newTitle;
      zikrs[index].count = newCount;
      zikrs[index].limit = newLimit;
      zikrs[index].category = newCategory;
    });
    await saveZikrs();
  }

  Future<void> deleteZikr(int index) async {
    setState(() {
      zikrs.removeAt(index);
    });
    await saveZikrs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zikr List'),
      ),
      body: ListView.builder(
        itemCount: zikrs.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.lightGreen[100],
              borderRadius: BorderRadius.circular(8), // Optional: Add border radius for rounded corners
            ),// Set the background color here
            child: ListTile(

              title: Text(zikrs[index].title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(zikrs[index].category),
                  Text('${zikrs[index].count} / ${zikrs[index].limit}'),
                ],
              ),
              onTap: () {
                setState(() {
                  if (zikrs[index].count < zikrs[index].limit) {
                    zikrs[index].count += 1;
                  } else {
                    zikrs[index].count = 1; // Reset count to 1 if it reaches the limit
                  }
                });
              },
              trailing: SizedBox(
                height: double.infinity, // Ensure the IconPopupMenu takes the full height of the ListTile
                child: Stack(
                  children: [
                    IconPopupMenu(
                      onAddPressed: () => updateZikr(
                          index, zikrs[index].title, zikrs[index].count + 1, zikrs[index].limit, zikrs[index].category),
                      onEditPressed: () => showEditDialog(context, index),
                      onDeletePressed: () => deleteZikr(index),
                    ),
                    const Positioned(
                      top: -5,
                      bottom: 0,
                      right: 0,
                      child: SizedBox(width: 48), // Adjust the width to create space for the IconPopupMenu
                    ),
                  ],
                ),
              ),
            ),
          );


        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddZikrPage(onAdd: addZikrLocally)),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void showEditDialog(BuildContext context, int index) {
    TextEditingController titleController =
        TextEditingController(text: zikrs[index].title);
    TextEditingController countController =
        TextEditingController(text: zikrs[index].count.toString());
    TextEditingController limitController =
        TextEditingController(text: zikrs[index].limit.toString());
    TextEditingController categoryController =
        TextEditingController(text: zikrs[index].category.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Zikrs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Zikr Title'),
              ),
              TextField(
                controller: countController,
                decoration: InputDecoration(labelText: 'Zikr Count'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: limitController,
                decoration: InputDecoration(labelText: 'Zikr Limit'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'Zikr Category'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                updateZikr(
                    index, titleController.text,
                    int.parse(countController.text),
                    int.parse(limitController.text),
                    categoryController.text
                );
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}

// #########################
class IconPopupMenu extends StatefulWidget {
  final VoidCallback onAddPressed;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  const IconPopupMenu({
    Key? key,
    required this.onAddPressed,
    required this.onEditPressed,
    required this.onDeletePressed,
  }) : super(key: key);

  @override
  _IconPopupMenuState createState() => _IconPopupMenuState();
}

class _IconPopupMenuState extends State<IconPopupMenu> {
  bool _showIcons = false;

  void _toggleIconsVisibility() {
    setState(() {
      _showIcons = !_showIcons;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        Visibility(
          visible: _showIcons,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  widget.onEditPressed();
                  _toggleIconsVisibility();
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  widget.onDeletePressed();
                  _toggleIconsVisibility();
                },
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: _toggleIconsVisibility,
        ),
      ],
    );
  }
}
// #########################


class AddZikrPage extends StatelessWidget {
  final Function(Zikr) onAdd;

  AddZikrPage({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    String zikrTitle = '';
    String zikrCategory = '';
    String zikrMeaning = '';
    int zikrLimit = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Zikr'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Zikr Title'),
              onChanged: (value) => zikrTitle = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Zikr Category'),
              onChanged: (value) => zikrCategory = value,
            ),TextField(
              decoration: InputDecoration(labelText: 'Zikr Meaning'),
              onChanged: (value) => zikrMeaning = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Zikr Limit'),
              onChanged: (value) {
                int? parsedLimit = int.tryParse(value);
                if (parsedLimit != null) {
                    zikrLimit = parsedLimit;
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (zikrTitle.isNotEmpty) {
                  onAdd(Zikr(title: zikrTitle, count: 0, meaning: zikrMeaning, category: zikrCategory, limit: zikrLimit));
                  Navigator.pop(context);
                }
              },
              child: Text('Add Zikr'),
            ),
          ],
        ),
      ),
    );
  }
}

class Zikr {
  String title;
  int count;
  String meaning;
  String category;
  int limit;

  Zikr({required this.title, required this.count, required this.meaning, required this.category, required this.limit});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'count': count,
    };
  }

  factory Zikr.fromJson(Map<String, dynamic> json) {
    return Zikr(
      title: json['title'],
      count: json['count'],
      meaning: json['meaning'],
      category: json['category'],
      limit: json['limit'],
    );
  }
}
