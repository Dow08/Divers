// ================================================================
// SORTIA — Écran Explorateur Complet (avec Riverpod)
// Navigation dossiers, import fichiers, templates, recherche
// ================================================================

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sortia/app/theme/app_colors.dart';
import 'package:sortia/app/theme/app_dimensions.dart';
import 'package:sortia/app/theme/app_typography.dart';
import 'package:sortia/features/auth/presentation/providers/auth_providers.dart';
import 'package:sortia/features/explorer/data/onboarding_templates.dart';
import 'package:sortia/features/explorer/domain/states/explorer_state.dart';
import 'package:sortia/features/explorer/presentation/providers/explorer_providers.dart';
import 'package:sortia/features/explorer/presentation/widgets/create_folder_dialog.dart';
import 'package:sortia/features/explorer/presentation/widgets/file_tile.dart';
import 'package:sortia/features/explorer/presentation/widgets/folder_tile.dart';

/// Écran principal de l'explorateur de documents
class ExplorerScreen extends ConsumerStatefulWidget {
  /// Crée l'écran explorateur
  const ExplorerScreen({super.key});

  @override
  ConsumerState<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends ConsumerState<ExplorerScreen> {
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    // Charger la racine au premier affichage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoadedOnce) {
        _hasLoadedOnce = true;
        ref.read(explorerProvider.notifier).loadRoot();
      }
    });
  }

  Future<void> _handleImportFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null || file.name.isEmpty) return;

    final explorerState = ref.read(explorerProvider);
    if (explorerState.currentFolderId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ouvrez un dossier avant d\'importer un fichier.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    await ref.read(explorerProvider.notifier).uploadFile(
          fileName: file.name,
          bytes: file.bytes!,
          mimeType: _getMimeType(file.name),
        );
  }

  String _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    const mimeMap = {
      'pdf': 'application/pdf',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'txt': 'text/plain',
      'csv': 'text/csv',
      'zip': 'application/zip',
    };
    return mimeMap[ext] ?? 'application/octet-stream';
  }

  @override
  Widget build(BuildContext context) {
    // Écoute des erreurs pour afficher un SnackBar
    ref.listen<ExplorerState>(
      explorerProvider,
      (previous, next) {
        if (next.errorMessage != null &&
            next.errorMessage != previous?.errorMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: Colors.red.shade800,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );

    final explorerState = ref.watch(explorerProvider);
    final currentUser = ref.watch(currentUserProvider);
    final userName = currentUser?.fullName ?? 'Utilisateur';
    final hasOnboarded = currentUser?.onboardingDone ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          explorerState.isRoot
              ? 'Mes Documents'
              : explorerState.breadcrumbs.isNotEmpty
                  ? explorerState.breadcrumbs.last.name
                  : 'Dossier',
        ),
        leading: explorerState.isRoot
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () =>
                    ref.read(explorerProvider.notifier).navigateUp(),
              ),
        actions: [
          IconButton(
            icon: Icon(
              explorerState.viewMode == ExplorerViewMode.list
                  ? Icons.grid_view_rounded
                  : Icons.view_list_rounded,
            ),
            tooltip: 'Changer vue',
            onPressed: () =>
                ref.read(explorerProvider.notifier).toggleViewMode(),
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Rechercher',
            onPressed: () {
              // TODO: Implémenter la barre de recherche
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Paramètres',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Fil d'Ariane
          if (explorerState.breadcrumbs.isNotEmpty) _buildBreadcrumbs(),

          // Contenu principal
          Expanded(
            child: explorerState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : explorerState.isEmpty && explorerState.isRoot && !hasOnboarded
                    ? _buildOnboardingView(userName)
                    : explorerState.isEmpty
                        ? _buildEmptyView()
                        : _buildContentView(explorerState),
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  /// Fil d'Ariane
  Widget _buildBreadcrumbs() {
    final breadcrumbs = ref.watch(breadcrumbsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySurface.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            InkWell(
              onTap: () =>
                  ref.read(explorerProvider.notifier).navigateToFolder(),
              child: const Row(
                children: [
                  Icon(Icons.home_rounded, size: 16, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text('Racine', style: TextStyle(color: AppColors.primary)),
                ],
              ),
            ),
            for (var i = 0; i < breadcrumbs.length; i++) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ),
              InkWell(
                onTap: i < breadcrumbs.length - 1
                    ? () => ref
                        .read(explorerProvider.notifier)
                        .navigateToFolder(folderId: breadcrumbs[i].id)
                    : null,
                child: Text(
                  breadcrumbs[i].name,
                  style: TextStyle(
                    color: i < breadcrumbs.length - 1
                        ? AppColors.primary
                        : AppColors.textPrimaryLight,
                    fontWeight: i == breadcrumbs.length - 1
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Vue d'onboarding (choix de template)
  Widget _buildOnboardingView(String userName) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          children: [
            Icon(
              Icons.folder_special_rounded,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text('Bonjour, $userName 👋', style: AppTypography.heading2),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              'Choisissez un modèle pour démarrer\nvotre espace documentaire.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            ...OnboardingTemplates.all.map((template) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
                child: SizedBox(
                  width: 360,
                  child: Card(
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        child: const Icon(
                          Icons.folder_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(template.name,
                          style: AppTypography.bodyLarge),
                      subtitle: Text(
                        template.description,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      trailing:
                          const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Utiliser "${template.name}" ?'),
                            content: Text(
                              'Cela créera une arborescence de dossiers '
                              'pré-configurée pour ${template.description.toLowerCase()}.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Annuler'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Créer'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await ref
                              .read(explorerProvider.notifier)
                              .applyTemplate(template.id);
                          // Marquer l'onboarding terminé
                          await ref
                              .read(authProvider.notifier)
                              .updateProfile(
                                onboardingDone: true,
                                templateChosen: template.id,
                              );
                        }
                      },
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Vue vide (dossier sans contenu)
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            'Ce dossier est vide',
            style: AppTypography.heading3.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            'Créez un sous-dossier ou importez un fichier.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Contenu principal (dossiers + fichiers)
  Widget _buildContentView(ExplorerState explorerState) {
    if (explorerState.viewMode == ExplorerViewMode.grid) {
      return _buildGridView(explorerState);
    }
    return _buildListView(explorerState);
  }

  Widget _buildListView(ExplorerState explorerState) {
    return ListView(
      padding: const EdgeInsets.only(
        top: AppDimensions.spacingSm,
        bottom: 80, // Espace pour le FAB
      ),
      children: [
        // Dossiers
        ...explorerState.folders.map((folder) => FolderTile(
              folder: folder,
              onTap: () => ref
                  .read(explorerProvider.notifier)
                  .navigateToFolder(folderId: folder.id),
              onRename: () async {
                final newName = await CreateFolderDialog.show(
                  context,
                  initialName: folder.name,
                  title: 'Renommer le dossier',
                );
                if (newName != null) {
                  await ref
                      .read(explorerProvider.notifier)
                      .renameFolder(folder.id, newName);
                }
              },
              onDelete: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Supprimer ce dossier ?'),
                    content: Text(
                      'Le dossier "${folder.name}" et tout son contenu '
                      'seront supprimés définitivement.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: const Text('Supprimer'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref
                      .read(explorerProvider.notifier)
                      .deleteFolder(folder.id);
                }
              },
            )),

        // Séparateur si dossiers + fichiers
        if (explorerState.folders.isNotEmpty && explorerState.files.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingLg,
              vertical: AppDimensions.spacingXs,
            ),
            child: Divider(),
          ),

        // Fichiers
        ...explorerState.files.map((file) => FileTile(
              file: file,
              onDelete: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Supprimer ce fichier ?'),
                    content: Text(
                      '"${file.name}" sera supprimé définitivement.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: const Text('Supprimer'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref
                      .read(explorerProvider.notifier)
                      .deleteFile(file.id, file.storagePath);
                }
              },
              onRename: () async {
                final newName = await CreateFolderDialog.show(
                  context,
                  initialName: file.name,
                  title: 'Renommer le fichier',
                );
                if (newName != null) {
                  await ref
                      .read(explorerProvider.notifier)
                      .renameFile(file.id, newName);
                }
              },
            )),
      ],
    );
  }

  Widget _buildGridView(ExplorerState explorerState) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        childAspectRatio: 1,
        crossAxisSpacing: AppDimensions.spacingSm,
        mainAxisSpacing: AppDimensions.spacingSm,
      ),
      itemCount: explorerState.folders.length,
      itemBuilder: (context, index) {
        final folder = explorerState.folders[index];
        return FolderGridTile(
          folder: folder,
          onTap: () => ref
              .read(explorerProvider.notifier)
              .navigateToFolder(folderId: folder.id),
        );
      },
    );
  }

  /// FAB avec menu d'actions
  Widget _buildFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.extended(
          heroTag: 'import_fab',
          onPressed: _handleImportFile,
          icon: const Icon(Icons.upload_file_rounded),
          label: const Text('Importer'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        FloatingActionButton(
          heroTag: 'folder_fab',
          onPressed: () async {
            final name = await CreateFolderDialog.show(context);
            if (name != null) {
              await ref.read(explorerProvider.notifier).createFolder(name: name);
            }
          },
          backgroundColor: AppColors.primarySurface,
          foregroundColor: AppColors.primary,
          mini: true,
          child: const Icon(Icons.create_new_folder_outlined),
        ),
      ],
    );
  }
}
