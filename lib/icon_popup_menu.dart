import 'dart:ffi';

import 'package:flutter/material.dart';

class IconPopupMenu extends StatefulWidget {
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onRedoPressed;
  final VoidCallback onFavoritePressed;
  final bool isFavorite;


  const IconPopupMenu({
    super.key,
    required this.onEditPressed,
    required this.onDeletePressed,
    required this.onRedoPressed,
    required this.onFavoritePressed,
    required this.isFavorite,
  });

  @override
  IconPopupMenuState createState() => IconPopupMenuState();
}

class IconPopupMenuState extends State<IconPopupMenu> {
  bool _showIcons = false;

  void _toggleIconsVisibility() {
    setState(() {
      _showIcons = !_showIcons;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
            children: [
              IconButton(
                icon: Icon(widget.isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () {
                  widget.onFavoritePressed(); // Add this line
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: _toggleIconsVisibility,
              ),
            ]
        ),
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

      ],
    );
  }
}
