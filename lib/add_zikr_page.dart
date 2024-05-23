import 'package:flutter/material.dart';
import 'zikr_model.dart';

class AddZikrPage extends StatefulWidget {
  final Future<void> Function(Zikr zikr) onAdd;

  const AddZikrPage({super.key, required this.onAdd});

  @override
  AddZikrPageState createState() => AddZikrPageState();
}

class AddZikrPageState extends State<AddZikrPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  bool _submitted = false;

  String? _validateTitle(String? value) {
    if (_submitted && (value == null || value.isEmpty)) {
      return 'Please enter a Zikr title';
    }
    return null;
  }

  String? _validateLimit(String? value) {
    if (_submitted) {
      if (value == null || value.isEmpty) {
        return 'Please enter a Zikr limit';
      }
      final isInteger = int.tryParse(value);
      if (isInteger == null) {
        return 'Please enter a valid integer for the Zikr limit';
      }
    }
    return null;
  }

  String? _validateCategory(String? value) {
    if (_submitted && (value == null || value.isEmpty)) {
      return 'Please enter a Zikr category';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Zikr'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                validator: _validateTitle,
                decoration: const InputDecoration(labelText: 'Zikr Title'),
              ),
              TextFormField(
                controller: _limitController,
                validator: _validateLimit,
                decoration: const InputDecoration(labelText: 'Zikr Limit'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _categoryController,
                validator: _validateCategory,
                decoration: const InputDecoration(labelText: 'Zikr Category'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _submitted = true;
                  });
                  if (_formKey.currentState!.validate()) {
                    final title = _titleController.text;
                    final limit = int.tryParse(_limitController.text) ?? 0;
                    final category = _categoryController.text;
                    final newZikr = Zikr(title: title, limit: limit, category: category);
                    widget.onAdd(newZikr);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Zikr', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}