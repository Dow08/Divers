// ================================================================
// SORTIA — Repository Explorer
// Couche data — accès Supabase (folders, files, storage)
// ================================================================

import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sortia/core/config/supabase_config.dart';
import 'package:sortia/core/error/app_exception.dart' as app;
import 'package:sortia/core/utils/logger.dart';
import 'package:sortia/features/explorer/data/onboarding_templates.dart';
import 'package:sortia/features/explorer/domain/models/file_model.dart';
import 'package:sortia/features/explorer/domain/models/folder_model.dart';

/// Repository pour la gestion des dossiers et fichiers
class ExplorerRepository {
  // ── Dossiers ──

  /// Charge les sous-dossiers d'un dossier (null = racine)
  Future<List<FolderModel>> fetchFolders({String? parentId}) async {
    try {
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) throw const app.AuthException('Non connecté.');

      var query = SupabaseConfig.client
          .from('folders')
          .select()
          .eq('user_id', userId)
          .eq('is_archived', false);

      if (parentId != null) {
        query = query.eq('parent_id', parentId);
      } else {
        query = query.isFilter('parent_id', null);
      }

      final data = await query.order('sort_order').order('name');

      return (data as List)
          .map((json) => FolderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error('Explorer: erreur chargement dossiers', e);
      rethrow;
    }
  }

  /// Crée un nouveau dossier
  Future<FolderModel> createFolder({
    required String name,
    String? parentId,
    String color = '#1B4F72',
    String icon = 'folder',
    String? description,
  }) async {
    try {
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) throw const app.AuthException('Non connecté.');

      // Calculer la profondeur
      var depth = 0;
      String? path = name;

      if (parentId != null) {
        final parent = await SupabaseConfig.client
            .from('folders')
            .select('depth, path')
            .eq('id', parentId)
            .single();
        depth = ((parent['depth'] as int?) ?? 0) + 1;
        final parentPath = (parent['path'] as String?) ?? '';
        path = '$parentPath/$name';
      }

      final data = await SupabaseConfig.client
          .from('folders')
          .insert({
            'user_id': userId,
            'name': name,
            'parent_id': parentId,
            'color': color,
            'icon': icon,
            'description': description,
            'depth': depth,
            'path': path,
          })
          .select()
          .single();

      AppLogger.info('Explorer: dossier créé — $name');
      return FolderModel.fromJson(data);
    } catch (e) {
      AppLogger.error('Explorer: erreur création dossier', e);
      rethrow;
    }
  }

  /// Renomme un dossier
  Future<void> renameFolder(String folderId, String newName) async {
    await SupabaseConfig.client
        .from('folders')
        .update({'name': newName})
        .eq('id', folderId);
  }

  /// Supprime un dossier (cascade les sous-dossiers et fichiers)
  Future<void> deleteFolder(String folderId) async {
    await SupabaseConfig.client.from('folders').delete().eq('id', folderId);
    AppLogger.info('Explorer: dossier supprimé — $folderId');
  }

  /// Récupère un dossier par son ID
  Future<FolderModel?> getFolderById(String folderId) async {
    try {
      final data = await SupabaseConfig.client
          .from('folders')
          .select()
          .eq('id', folderId)
          .single();
      return FolderModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Construit le fil d'Ariane jusqu'à un dossier
  Future<List<FolderModel>> buildBreadcrumbs(String? folderId) async {
    if (folderId == null) return [];

    final breadcrumbs = <FolderModel>[];
    String? currentId = folderId;

    while (currentId != null) {
      final folder = await getFolderById(currentId);
      if (folder == null) break;
      breadcrumbs.insert(0, folder);
      currentId = folder.parentId;
    }

    return breadcrumbs;
  }

  // ── Fichiers ──

  /// Charge les fichiers d'un dossier
  Future<List<FileModel>> fetchFiles(String folderId) async {
    try {
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) throw const app.AuthException('Non connecté.');

      final data = await SupabaseConfig.client
          .from('files')
          .select()
          .eq('user_id', userId)
          .eq('folder_id', folderId)
          .eq('is_archived', false)
          .eq('is_latest_version', true)
          .order('created_at', ascending: false);

      return (data as List)
          .map((json) => FileModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error('Explorer: erreur chargement fichiers', e);
      rethrow;
    }
  }

  /// Upload un fichier vers Supabase Storage + insertion BDD
  Future<FileModel> uploadFile({
    required String folderId,
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) throw const app.AuthException('Non connecté.');

    // Chemin de stockage unique
    final storagePath = '$userId/$folderId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    try {
      // Upload vers Supabase Storage
      await SupabaseConfig.client.storage
          .from('documents')
          .uploadBinary(storagePath, bytes, fileOptions: FileOptions(
            contentType: mimeType,
          ));

      // Insertion en BDD
      final data = await SupabaseConfig.client
          .from('files')
          .insert({
            'user_id': userId,
            'folder_id': folderId,
            'name': fileName,
            'original_name': fileName,
            'mime_type': mimeType,
            'size_bytes': bytes.length,
            'storage_path': storagePath,
            'storage_bucket': 'documents',
          })
          .select()
          .single();

      AppLogger.info('Explorer: fichier uploadé — $fileName (${bytes.length} octets)');
      return FileModel.fromJson(data);
    } catch (e) {
      AppLogger.error('Explorer: erreur upload fichier', e);
      rethrow;
    }
  }

  /// Supprime un fichier (storage + BDD)
  Future<void> deleteFile(String fileId, String storagePath) async {
    try {
      await SupabaseConfig.client.storage.from('documents').remove([storagePath]);
      await SupabaseConfig.client.from('files').delete().eq('id', fileId);
      AppLogger.info('Explorer: fichier supprimé — $fileId');
    } catch (e) {
      AppLogger.error('Explorer: erreur suppression fichier', e);
      rethrow;
    }
  }

  /// Renomme un fichier
  Future<void> renameFile(String fileId, String newName) async {
    await SupabaseConfig.client
        .from('files')
        .update({'name': newName})
        .eq('id', fileId);
  }

  // ── Recherche ──

  /// Recherche plein texte dans les fichiers
  Future<List<FileModel>> searchFiles(String query) async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return [];

    try {
      final data = await SupabaseConfig.client
          .from('files')
          .select()
          .eq('user_id', userId)
          .textSearch('search_vector', query, config: 'french')
          .limit(50);

      return (data as List)
          .map((json) => FileModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error('Explorer: erreur recherche', e);
      return [];
    }
  }

  // ── Templates d'onboarding ──

  /// Crée l'arborescence de dossiers à partir d'un template
  Future<void> createTemplateFolders(String templateId) async {
    final templateDefs = OnboardingTemplates.getTemplate(templateId);
    if (templateDefs.isEmpty) return;

    for (final folderDef in templateDefs) {
      await _createFolderRecursive(folderDef, null);
    }

    AppLogger.info('Explorer: template "$templateId" créé');
  }

  Future<void> _createFolderRecursive(
    TemplateFolderDef def,
    String? parentId,
  ) async {
    final folder = await createFolder(
      name: def.name,
      parentId: parentId,
      color: def.color,
      icon: def.icon,
    );

    for (final child in def.children) {
      await _createFolderRecursive(child, folder.id);
    }
  }
}
