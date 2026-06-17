// ================================================================
// SORTIA — Module Notes
// Modèle + Repository + Providers + Écran
// Types : text, checklist, photo, voice, table
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sortia/core/utils/logger.dart';

// ── Modèle ───────────────────────────────────────────────────

enum NoteType {
  text('Texte', Icons.article_outlined, '📝'),
  checklist('Checklist', Icons.checklist_outlined, '✅'),
  photo('Photo', Icons.photo_outlined, '📷'),
  voice('Vocal', Icons.mic_outlined, '🎙️'),
  table('Tableau', Icons.table_chart_outlined, '📊');

  const NoteType(this.label, this.icon, this.emoji);
  final String label;
  final IconData icon;
  final String emoji;

  static NoteType fromString(String value) {
    return NoteType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NoteType.text,
    );
  }
}

class NoteModel {
  const NoteModel({
    required this.id,
    required this.userId,
    this.folderId,
    required this.type,
    this.title,
    this.content = const {},
    this.audioUrl,
    this.transcript,
    this.isPinned = false,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String? folderId;
  final NoteType type;
  final String? title;
  final Map<String, dynamic> content;
  final String? audioUrl;
  final String? transcript;
  final bool isPinned;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Texte brut de la note
  String get textContent => content['text'] as String? ?? '';

  /// Items de checklist
  List<Map<String, dynamic>> get checklistItems {
    final items = content['items'];
    if (items is List) return items.cast<Map<String, dynamic>>();
    return [];
  }

  /// Aperçu de la note (50 caractères max)
  String get preview {
    if (title != null && title!.isNotEmpty) return title!;
    if (textContent.isNotEmpty) {
      return textContent.length > 50
          ? '${textContent.substring(0, 50)}…'
          : textContent;
    }
    return '${type.emoji} ${type.label}';
  }

  /// Date formatée
  String get dateFormatted {
    final d = updatedAt ?? createdAt;
    if (d == null) return '';
    return '${d.day}/${d.month}/${d.year}';
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        folderId: json['folder_id'] as String?,
        type: NoteType.fromString(json['type'] as String),
        title: json['title'] as String?,
        content: json['content'] != null
            ? Map<String, dynamic>.from(json['content'] as Map)
            : {},
        audioUrl: json['audio_url'] as String?,
        transcript: json['transcript'] as String?,
        isPinned: (json['is_pinned'] as bool?) ?? false,
        tags: (json['tags'] as List?)?.cast<String>() ?? [],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'folder_id': folderId,
        'type': type.name,
        'title': title,
        'content': content,
        'audio_url': audioUrl,
        'transcript': transcript,
        'is_pinned': isPinned,
        'tags': tags,
      };

  NoteModel copyWith({
    String? title,
    Map<String, dynamic>? content,
    bool? isPinned,
    List<String>? tags,
  }) =>
      NoteModel(
        id: id,
        userId: userId,
        folderId: folderId,
        type: type,
        title: title ?? this.title,
        content: content ?? this.content,
        audioUrl: audioUrl,
        transcript: transcript,
        isPinned: isPinned ?? this.isPinned,
        tags: tags ?? this.tags,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}

// ── Repository ───────────────────────────────────────────────

class NotesRepository {
  NotesRepository(this._supabase);
  final SupabaseClient _supabase;

  String get _uid => _supabase.auth.currentUser!.id;

  Future<List<NoteModel>> fetchNotes({String? folderId}) async {
    try {
      var query = _supabase
          .from('notes')
          .select()
          .eq('user_id', _uid);

      if (folderId != null) query = query.eq('folder_id', folderId);

      final data = await query.order('is_pinned', ascending: false)
          .order('updated_at', ascending: false);

      return (data as List)
          .map((r) => NoteModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      AppLogger.error('NotesRepository.fetchNotes', e, st);
      rethrow;
    }
  }

  Future<NoteModel> createNote(NoteModel note) async {
    try {
      final data = await _supabase
          .from('notes')
          .insert(note.toJson())
          .select()
          .single();
      return NoteModel.fromJson(data);
    } catch (e, st) {
      AppLogger.error('NotesRepository.createNote', e, st);
      rethrow;
    }
  }

  Future<void> updateNote(NoteModel note) async {
    try {
      await _supabase
          .from('notes')
          .update({
            'title': note.title,
            'content': note.content,
            'is_pinned': note.isPinned,
            'tags': note.tags,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', note.id)
          .eq('user_id', _uid);
    } catch (e, st) {
      AppLogger.error('NotesRepository.updateNote', e, st);
      rethrow;
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _supabase
          .from('notes')
          .delete()
          .eq('id', noteId)
          .eq('user_id', _uid);
    } catch (e, st) {
      AppLogger.error('NotesRepository.deleteNote', e, st);
      rethrow;
    }
  }
}

// ── Providers ────────────────────────────────────────────────

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(Supabase.instance.client);
});

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<NoteModel>>(NotesNotifier.new);

class NotesNotifier extends AsyncNotifier<List<NoteModel>> {
  @override
  Future<List<NoteModel>> build() async {
    return ref.read(notesRepositoryProvider).fetchNotes();
  }

  Future<void> create(NoteModel note) async {
    final created =
        await ref.read(notesRepositoryProvider).createNote(note);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([created, ...current]);
  }

  Future<void> updateNote(NoteModel note) async {
    await ref.read(notesRepositoryProvider).updateNote(note);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current.map((n) => n.id == note.id ? note : n).toList(),
    );
  }

  Future<void> deleteNote(String noteId) async {
    await ref.read(notesRepositoryProvider).deleteNote(noteId);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current.where((n) => n.id != noteId).toList(),
    );
  }

  Future<void> togglePin(NoteModel note) async {
    final updated = note.copyWith(isPinned: !note.isPinned);
    await updateNote(updated);
  }
}

// ── Écran Notes ──────────────────────────────────────────────

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(
        title: const Text('Notes'),
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (notes) => notes.isEmpty
            ? _EmptyNotes()
            : _NotesList(notes: notes),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9E7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.note_add_outlined,
                size: 48, color: Color(0xFFD4AC0D)),
          ),
          const SizedBox(height: 16),
          const Text('Aucune note',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 8),
          const Text('Créez des notes texte, checklists,\nvocales ou tableaux',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF566573))),
        ],
      ),
    );
  }
}

class _NotesList extends ConsumerWidget {
  const _NotesList({required this.notes});
  final List<NoteModel> notes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (_, i) {
        final note = notes[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF5FB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(note.type.icon,
                  color: const Color(0xFF2E86C1), size: 20),
            ),
            title: Text(note.preview,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            subtitle: Row(
              children: [
                if (note.isPinned)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(Icons.push_pin,
                        size: 12, color: Color(0xFFE67E22)),
                  ),
                Text(note.dateFormatted,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF566573))),
                if (note.tags.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text('🏷 ${note.tags.length}',
                      style: const TextStyle(fontSize: 11)),
                ],
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert, size: 18),
              onPressed: () {},
            ),
            onTap: () {},
          ),
        );
      },
    );
  }
}
