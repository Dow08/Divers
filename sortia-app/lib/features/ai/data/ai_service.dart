// ================================================================
// SORTIA — Service IA (Google Gemini)
// Classification automatique de documents
// ================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:sortia/core/config/env.dart';
import 'package:sortia/core/utils/logger.dart';
import 'package:sortia/features/ai/domain/classification_types.dart';

/// Service d'intelligence artificielle basé sur Google Gemini
///
/// Fournit la classification automatique de documents,
/// l'extraction de métadonnées, et le résumé de contenu.
class AiService {
  AiService._();

  static GenerativeModel? _model;
  static GenerativeModel? _visionModel;

  /// Initialise les modèles Gemini
  static void initialize() {
    final apiKey = Env.geminiApiKey;
    if (apiKey.isEmpty) {
      AppLogger.warning('IA: clé Gemini non configurée');
      return;
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    _visionModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    AppLogger.info('IA: service Gemini initialisé');
  }

  /// Vérifie si le service est disponible
  static bool get isAvailable => _model != null;

  // ── Classification de document ──

  /// Classifie un document à partir de son texte extrait
  static Future<AiClassificationResult> classifyFromText(String text) async {
    if (!isAvailable) {
      return const AiClassificationResult(
        category: DocumentCategory.autre,
        confidence: 0.0,
      );
    }

    try {
      final prompt = _buildClassificationPrompt(text);
      final response = await _model!.generateContent([Content.text(prompt)]);
      final result = response.text ?? '';

      return _parseClassificationResponse(result);
    } catch (e) {
      AppLogger.error('IA: erreur classification texte', e);
      return const AiClassificationResult(
        category: DocumentCategory.autre,
        confidence: 0.0,
      );
    }
  }

  /// Classifie un document à partir d'une image (scan, photo)
  static Future<AiClassificationResult> classifyFromImage(
    Uint8List imageBytes,
    String mimeType,
  ) async {
    if (_visionModel == null) {
      return const AiClassificationResult(
        category: DocumentCategory.autre,
        confidence: 0.0,
      );
    }

    try {
      final prompt = _buildVisionPrompt();
      final imagePart = DataPart(mimeType, imageBytes);

      final response = await _visionModel!.generateContent([
        Content.multi([TextPart(prompt), imagePart]),
      ]);
      final result = response.text ?? '';

      return _parseClassificationResponse(result);
    } catch (e) {
      AppLogger.error('IA: erreur classification image', e);
      return const AiClassificationResult(
        category: DocumentCategory.autre,
        confidence: 0.0,
      );
    }
  }

  // ── Résumé ──

  /// Génère un résumé d'un document
  static Future<String> summarize(String text) async {
    if (!isAvailable) return '';

    try {
      final prompt = '''
Tu es un assistant documentaire français. Résume ce document en 2-3 phrases maximum.
Sois concis et factuel.

DOCUMENT :
$text
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? '';
    } catch (e) {
      AppLogger.error('IA: erreur résumé', e);
      return '';
    }
  }

  // ── Prompts privés ──

  static String _buildClassificationPrompt(String text) {
    return '''
Tu es un assistant de classification documentaire pour une application française de gestion administrative (TPE/PME et particuliers).

Analyse le texte suivant et réponds UNIQUEMENT en JSON strict avec ces champs :
{
  "category": "une des catégories ci-dessous",
  "confidence": 0.0 à 1.0,
  "suggested_name": "nom de fichier suggéré",
  "vendor_name": "nom du fournisseur ou émetteur si détecté",
  "document_date": "YYYY-MM-DD si détectée",
  "document_amount": 0.00 si montant détecté ou null,
  "document_number": "numéro du document si détecté",
  "summary": "résumé en une phrase",
  "suggested_folder": "nom du dossier suggéré",
  "tags": ["tag1", "tag2"]
}

CATÉGORIES POSSIBLES :
Facture, Devis, Bon de commande, Bon de livraison, Relevé bancaire,
Bulletin de paie, Contrat, Attestation, Avis d'imposition,
Déclaration fiscale, Pièce d'identité, Assurance, Courrier,
Note de frais, Document santé, Document scolaire, Autre

TEXTE DU DOCUMENT :
$text
''';
  }

  static String _buildVisionPrompt() {
    return '''
Tu es un assistant de classification documentaire français.
Analyse cette image de document et réponds UNIQUEMENT en JSON strict :
{
  "category": "catégorie du document",
  "confidence": 0.0 à 1.0,
  "suggested_name": "nom de fichier suggéré",
  "vendor_name": "fournisseur ou émetteur",
  "document_date": "YYYY-MM-DD",
  "document_amount": 0.00 ou null,
  "document_number": "numéro si visible",
  "summary": "résumé en une phrase",
  "suggested_folder": "dossier suggéré",
  "tags": ["tag1", "tag2"]
}

CATÉGORIES : Facture, Devis, Contrat, Bulletin de paie, Relevé bancaire,
Avis d'imposition, Assurance, Pièce d'identité, Courrier, Note de frais, Autre
''';
  }

  // ── Parsing de la réponse ──

  static AiClassificationResult _parseClassificationResponse(String raw) {
    try {
      // Extraire le JSON de la réponse (enlever markdown si présent)
      var jsonStr = raw.trim();
      if (jsonStr.contains('```json')) {
        jsonStr = jsonStr.split('```json').last.split('```').first.trim();
      } else if (jsonStr.contains('```')) {
        jsonStr = jsonStr.split('```')[1].trim();
      }

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      return AiClassificationResult(
        category: DocumentCategory.fromLabel(
          (json['category'] as String?) ?? 'Autre',
        ),
        confidence: ((json['confidence'] as num?) ?? 0.5).toDouble(),
        suggestedName: json['suggested_name'] as String?,
        vendorName: json['vendor_name'] as String?,
        documentDate: json['document_date'] as String?,
        documentAmount: json['document_amount'] != null
            ? double.tryParse(json['document_amount'].toString())
            : null,
        documentNumber: json['document_number'] as String?,
        summary: json['summary'] as String?,
        suggestedFolder: json['suggested_folder'] as String?,
        tags: (json['tags'] as List<dynamic>?)
                ?.map((t) => t.toString())
                .toList() ??
            [],
      );
    } catch (e) {
      AppLogger.warning('IA: erreur parsing réponse — $e');
      return const AiClassificationResult(
        category: DocumentCategory.autre,
        confidence: 0.0,
      );
    }
  }
}
