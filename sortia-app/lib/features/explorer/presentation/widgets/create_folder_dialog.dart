// ================================================================
// SORTIA — Dialog Création Dossier
// ================================================================

import 'package:flutter/material.dart';
import 'package:sortia/app/theme/app_colors.dart';
import 'package:sortia/app/theme/app_dimensions.dart';

/// Dialog pour créer ou renommer un dossier
class CreateFolderDialog extends StatefulWidget {
  /// Dialog pour créer un dossier
  const CreateFolderDialog({
    super.key,
    this.initialName,
    this.title = 'Nouveau dossier',
  });

  /// Dialog pour renommer un dossier
  const CreateFolderDialog.rename({
    super.key,
    required String this.initialName,
  }) : title = 'Renommer le dossier';

  final String? initialName;
  final String title;

  /// Affiche le dialog et retourne le nom saisi (ou null si annulé)
  static Future<String?> show(
    BuildContext context, {
    String? initialName,
    String title = 'Nouveau dossier',
  }) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => CreateFolderDialog(
        initialName: initialName,
        title: title,
      ),
    );
  }

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  late final TextEditingController _controller;
  String _selectedColor = '#1B4F72';

  static const _colors = [
    '#1B4F72',
    '#117A65',
    '#6C3483',
    '#A93226',
    '#B7950B',
    '#2874A6',
    '#D4AC0D',
    '#616161',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Nom du dossier',
              prefixIcon: Icon(
                Icons.folder_rounded,
                color: _parseColor(_selectedColor),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          const Text('Couleur :'),
          const SizedBox(height: AppDimensions.spacingXs),
          Wrap(
            spacing: 8,
            children: _colors.map((hex) {
              final isSelected = hex == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = hex),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _parseColor(hex),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _parseColor(hex).withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.initialName != null ? 'Renommer' : 'Créer'),
        ),
      ],
    );
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      Navigator.pop(context, name);
    }
  }
}
