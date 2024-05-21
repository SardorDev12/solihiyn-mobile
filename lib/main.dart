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
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
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
          return MaterialApp(
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

  void toggleTheme() {
    _currentTheme = _currentTheme == darkTheme ? lightTheme : darkTheme;
    _saveToPrefs();
    notifyListeners();
  }
}

final lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: const Color.fromARGB(255, 151, 136, 117),
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: const Color.fromARGB(255, 255, 255, 255),
  ),
);

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Zikr List'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
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
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.lightGreen[100],
              borderRadius: BorderRadius.circular(8),
            ),
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
        child: Icon(Icons.add),
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
          title: Text('Edit Zikr'),
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
                    index,
                    titleController.text,
                    int.parse(countController.text),
                    int.parse(limitController.text),
                    categoryController.text);
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
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: _toggleIconsVisibility,
        ),
        Visibility(
          visible: _showIcons,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: widget.onAddPressed,
              ),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: widget.onEditPressed,
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: widget.onDeletePressed,
              ),
            ],
          ),
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
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Zikr'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Zikr Title'),
            ),
            TextField(
              controller: _countController,
              decoration: InputDecoration(labelText: 'Zikr Count'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _limitController,
              decoration: InputDecoration(labelText: 'Zikr Limit'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Zikr Category'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text;
                final count = int.parse(_countController.text);
                final limit = int.parse(_limitController.text);
                final category = _categoryController.text;
                final newZikr = Zikr(title: title, count: count, limit: limit, category: category);
                onAdd(newZikr);
                Navigator.pop(context);
              },
              child: Text('Add Zikrs'),
            ),
          ],
        ),
      ),
    );
  }
}
