import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: Text("Solihiyn Zikrs"),
            ),
          ),);
        } else if (snapshot.connectionState == ConnectionState.done) {
          return ChangeNotifierProvider<ThemeNotifier>(
            create: (_) => ThemeNotifier().._loadFromPrefs(),
            child: Consumer<ThemeNotifier>(
              builder: (context, theme, child) {
                return MaterialApp(
                  title: 'Flutter',
                  theme: theme.getTheme(),
                  home: const ZikrList(),
                );
              },
            ),
          );
        } else {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error loading preferences')),
            ),
          );
        }
      },
    );
  }
}

class ThemeNotifier extends ChangeNotifier {
  ThemeData _currentTheme = lightTheme;
  SharedPreferences? _prefs;
  bool _isLoaded = false;

  ThemeNotifier() {
    _loadFromPrefs();
  }

  ThemeData getTheme() => _currentTheme;
  bool get isLoaded => _isLoaded;

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _loadFromPrefs() async {
    await _initPrefs();
    final isDarkMode = _prefs?.getBool('isDarkMode') ?? false;
    _currentTheme = isDarkMode ? darkTheme : lightTheme;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    await _initPrefs();
    _prefs?.setBool('isDarkMode', _currentTheme == darkTheme);
  }


  void toggleTheme() async{
    _currentTheme = _currentTheme == darkTheme ? lightTheme : darkTheme;


    _saveToPrefs();
    notifyListeners();

  }
}

final lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color.fromARGB(255, 151, 136, 117),
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color.fromARGB(255, 44, 99, 119),
  ),
);



class ZikrList extends StatefulWidget {
  const ZikrList({super.key});

  @override
  _ZikrListState createState() => _ZikrListState();
}

class _ZikrListState extends State<ZikrList> {
  List<Zikr> zikrs = [];
  Color? _containerColor;


  @override
  void initState() {
    super.initState();
    _containerColor = Colors.lightGreen[100];
    loadZikrs();
  }

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
      if (await file.exists()) {
        final contents = await file.readAsString();
        final jsonResponse = jsonDecode(contents) as List;
        setState(() {
          zikrs = jsonResponse.map((data) => Zikr.fromJson(data)).toList();
        });
      } else {
        setState(() {
          zikrs = [];
        });
      }
    } catch (e) {
      setState(() {
        zikrs = [];
      });
    }
  }

  Future<File> saveZikrs() async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode(zikrs.map((zikr) => zikr.toJson()).toList()));
  }

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
    _containerColor = Provider.of<ThemeNotifier>(context).getTheme() == darkTheme
        ? Colors.blueAccent[200]
        : Colors.lightGreen[100];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zikr List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: zikrs.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
            decoration: BoxDecoration(
              color: _containerColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: Text(zikrs[index].category,style: const TextStyle(decoration: TextDecoration.underline)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      zikrs[index].title,
                      style: const TextStyle(fontSize: 25),
                    ),
                  ),
                  Text(
                    '${zikrs[index].count} / ${zikrs[index].limit}',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  if (zikrs[index].count < zikrs[index].limit) {
                    zikrs[index].count += 1;
                  }else{
                    zikrs[index].count = 1;
                  }
                });
                saveZikrs();
              },
              trailing: SizedBox(
                height: double.infinity,
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
                      child: SizedBox(width: 48),
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
            MaterialPageRoute(builder: (context) => AddZikrPage(onAdd: addZikrLocally)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }



  void showEditDialog(BuildContext context, int index) {
    TextEditingController titleController = TextEditingController(text: zikrs[index].title);
    TextEditingController countController = TextEditingController(text: zikrs[index].count.toString());
    TextEditingController limitController = TextEditingController(text: zikrs[index].limit.toString());
    TextEditingController categoryController = TextEditingController(text: zikrs[index].category.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Zikr'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Zikr Title'),
              ),
              TextField(
                controller: countController,
                decoration: const InputDecoration(labelText: 'Zikr Count'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: limitController,
                decoration: const InputDecoration(labelText: 'Zikr Limit'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Zikr Category'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                updateZikr(
                    index,
                    titleController.text,
                    int.parse(countController.text),
                    int.parse(limitController.text),
                    categoryController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
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
    super.key,
    required this.onAddPressed,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

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
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  widget.onEditPressed();
                  _toggleIconsVisibility();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  widget.onDeletePressed();
                  _toggleIconsVisibility();
                },
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: _toggleIconsVisibility,
        ),
      ],
    );
  }
}

class Zikr {
  String title;
  int count;
  int limit;
  String category;

  Zikr({required this.title, this.count = 0, this.limit = 100, this.category = ''});

  factory Zikr.fromJson(Map<String, dynamic> json) {
    return Zikr(
      title: json['title'],
      count: json['count'],
      limit: json['limit'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'count': count,
      'limit': limit,
      'category': category,
    };
  }
}

class AddZikrPage extends StatelessWidget {
  final Future<void> Function(Zikr zikr) onAdd;

  AddZikrPage({super.key, required this.onAdd});

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Zikr'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Zikr Title'),
            ),
            TextField(
              controller: _limitController,
              decoration: const InputDecoration(labelText: 'Zikr Limit'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Zikr Category'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text;
                final limit = int.parse(_limitController.text);
                final category = _categoryController.text;
                final newZikr = Zikr(title: title, limit: limit, category: category);
                onAdd(newZikr);
                Navigator.pop(context);
              },
              child: const Text('Add Zikr'),
            ),
          ],
        ),
      ),
    );
  }
}
