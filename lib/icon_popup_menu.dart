import 'package:flutter/material.dart';

class IconPopupMenu extends StatefulWidget {
  final VoidCallback onResetZikrCount;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onRedoPressed;
  final VoidCallback onFavoritePressed;
  final bool isFavorite;


  const IconPopupMenu({
    super.key,
    required this.onResetZikrCount,
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
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(maxWidth: 1),

                onPressed: () {
                  widget.onResetZikrCount();
                }
              ),
              IconButton(
                icon: Icon(widget.isFavorite ? Icons.favorite : Icons.favorite_border),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(maxWidth: 1),

                onPressed: () {
                  widget.onFavoritePressed();
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(maxWidth: 1),
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
