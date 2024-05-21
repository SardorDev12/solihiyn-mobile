import 'package:flutter/material.dart';
import 'zikr_model.dart';

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
              child: const Text('Add Zikr', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
