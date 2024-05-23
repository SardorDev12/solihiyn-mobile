import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'zikr_model.dart';
import 'add_zikr_page.dart';
import 'icon_popup_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZikrList extends StatefulWidget {
  const ZikrList({super.key});

  @override
  ZikrListState createState() => ZikrListState();
}

class ZikrListState extends State<ZikrList> {
  List<Zikr> zikrs = [];
  bool isAscending = true;
  Color? _containerColor;
  bool showFav = false;
  late SharedPreferences _prefs;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _containerColor = Colors.lightGreen[100];
    _loadPrefs();
    loadZikrs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _isFavorite = _prefs.getBool('isFavorite') ?? false;
    setState(() {});
  }

  Future<void> _savePrefs() async {
    await _prefs.setBool('isFavorite', _isFavorite);

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

    final defaultZikr = [Zikr(
      title: 'Subhanalloh',
      count: 0,
      limit: 33,
      category: 'Namozdan keyingi zikrlar',
      isFavourite: false,
      isDone: false,
    ),
   Zikr(
      title: 'Alhamdulillah',
      count: 0,
      limit: 33,
      category: 'Namozdan keyingi zikrlar',
      isFavourite: false,
      isDone: false,
    ),
    Zikr(
      title: 'Allohu Akbar',
      count: 0,
      limit: 33,
      category: 'Namozdan keyingi zikrlar',
      isFavourite: false,
      isDone: false,
    )];


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
          zikrs = [...defaultZikr];
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

  Future<void> redo(int index) async {
    setState(() {
      zikrs[index].isDone = false;
    });
    await saveZikrs();
  }

  Future<void> increment(int index) async {
    setState(() {
      if (zikrs[index].count < zikrs[index].limit - 1 && !zikrs[index].isDone) {
        zikrs[index].count += 1;
      } else {
        zikrs[index].count = -1;
        zikrs[index].isDone = true;
      }
    });
    await saveZikrs();
  }

  void toggleSortOrder() {
    setState(() {
      isAscending = !isAscending;
      zikrs.sort((a, b) => isAscending ? a.createdTime.compareTo(b.createdTime) : b.createdTime.compareTo(a.createdTime));
    });
  }

  void _toggleFavoriteFilter() {
    setState(() {
      showFav = !showFav;
      _savePrefs();
    });
  }

  Future<void> toggleFavorite(int index) async {
    setState(() {
      zikrs[index].isFavourite = !zikrs[index].isFavourite;
    });
    await saveZikrs();

  }


  @override
  Widget build(BuildContext context) {
    _containerColor = Provider.of<ThemeNotifier>(context).getTheme() == darkTheme
        ? Colors.blueAccent[200]
        : Colors.lightGreen[100];
    List<Zikr> displayedZikrs = showFav ? zikrs.where((zikr) => zikr.isFavourite).toList() : zikrs;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solihiyn Zikrs'),
        actions: [

          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: toggleSortOrder,
          ),
          IconButton(
            icon: Icon(showFav ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavoriteFilter,
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddZikrPage(onAdd: addZikrLocally)),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: displayedZikrs.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
            decoration: BoxDecoration(
              color: _containerColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                ListTile(
                  title: Text(
                    displayedZikrs[index].isDone ? "" : displayedZikrs[index].category,
                    style: const TextStyle(decoration: TextDecoration.underline),
                  ),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          displayedZikrs[index].isDone = false;
                          increment(index);
                        });
                      },
                      child: Text.rich(
                        TextSpan(
                          children: [
                            if(displayedZikrs[index].isDone)
                            const WidgetSpan(
                              child: Icon(
                                Icons.redo_sharp,
                                size: 22,
                              ),
                            ),
                            TextSpan(
                              text: displayedZikrs[index].isDone ? " Redo" : displayedZikrs[index].title,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ],
                        ),
                      ),
                    ),
                      ),
                    Text(displayedZikrs[index].isDone ? "" :
                    '${displayedZikrs[index].count} / ${displayedZikrs[index].limit}',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  increment(index);
                });
                saveZikrs();
              },
                ),
                Positioned(
                  top: 0,
                  right: 0,
                child: IconPopupMenu(
                      onEditPressed: () => showEditDialog(context, index),
                      onDeletePressed: () => deleteZikr(index),onRedoPressed: ()=> redo(index),
                      onFavoritePressed: () => toggleFavorite(index), // Add this line
                      isFavorite: displayedZikrs[index].isFavourite,
                    ),
                )
            ],

            ),
          );
        },
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
