import 'package:flutter/material.dart';

class IconPopupMenu extends StatefulWidget {
  // final VoidCallback onAddPressed;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  const IconPopupMenu({
    super.key,
    // required this.onAddPressed,
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
