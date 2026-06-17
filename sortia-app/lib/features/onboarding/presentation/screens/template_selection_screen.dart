// ================================================================
// SORTIA — Écran Sélection de Template (Onboarding étape 2)
// Choix d'une arborescence prédéfinie
// ================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sortia/features/explorer/data/onboarding_templates.dart';

class TemplateSelectionScreen extends StatefulWidget {
  const TemplateSelectionScreen({super.key});

  @override
  State<TemplateSelectionScreen> createState() =>
      _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(
        title: const Text('Choisissez votre profil'),
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1B4F72),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: const Text(
              'SORTIA créera automatiquement une\narborescence de dossiers adaptée à\nvotre activité.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFAED6F1),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Liste des templates
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: OnboardingTemplates.all.length,
              itemBuilder: (_, i) {
                final tpl = OnboardingTemplates.all[i];
                final isSelected = _selectedId == tpl.id;
                return _TemplateCard(
                  template: tpl,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedId = tpl.id),
                );
              },
            ),
          ),

          // Bouton Continuer
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedId != null
                    ? () => _onContinue()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF17A589),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFD5D8DC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _selectedId != null
                      ? 'Créer mon espace'
                      : 'Sélectionnez un profil',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onContinue() {
    // Récupère les dossiers du template sélectionné
    final folders = OnboardingTemplates.getTemplate(_selectedId!);
    final templateName =
        OnboardingTemplates.all.firstWhere((t) => t.id == _selectedId).name;

    // Affiche une confirmation et navigue vers l'explorer
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('✅ Espace créé !'),
        content: Text(
          'Votre arborescence "$templateName" a été créée '
          'avec ${_countFolders(folders)} dossiers.\n\n'
          'Vous pouvez maintenant commencer à importer vos documents.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF17A589),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Commencer'),
          ),
        ],
      ),
    );
  }

  int _countFolders(List<TemplateFolderDef> folders) {
    int count = 0;
    for (final f in folders) {
      count += 1 + _countFolders(f.children);
    }
    return count;
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  final TemplateInfo template;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final folders = OnboardingTemplates.getTemplate(template.id);
    final folderCount = _count(folders);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1B4F72)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1B4F72).withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1B4F72).withValues(alpha: 0.1)
                    : const Color(0xFFF4F6F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconFor(template.icon),
                color: isSelected
                    ? const Color(0xFF1B4F72)
                    : const Color(0xFF566573),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF1B4F72)
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    template.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF566573),
                    ),
                  ),
                  if (folderCount > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '$folderCount dossiers prédéfinis',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF2E86C1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: Color(0xFF17A589), size: 24),
          ],
        ),
      ),
    );
  }

  int _count(List<TemplateFolderDef> folders) {
    int c = 0;
    for (final f in folders) {
      c += 1 + _count(f.children);
    }
    return c;
  }

  IconData _iconFor(String icon) => switch (icon) {
        'work' => Icons.work_outline,
        'home' => Icons.home_outlined,
        'folder' => Icons.folder_outlined,
        _ => Icons.folder_outlined,
      };
}
