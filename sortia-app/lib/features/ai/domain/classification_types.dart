// ================================================================
// SORTIA — Types de classification IA
// Catégories de documents reconnues par le moteur IA
// ================================================================

/// Catégorie de document détectée par l'IA
enum DocumentCategory {
  /// Facture (achat ou vente)
  facture('Facture', 'money'),

  /// Devis / Estimation
  devis('Devis', 'money'),

  /// Bon de commande
  bonCommande('Bon de commande', 'money'),

  /// Bon de livraison
  bonLivraison('Bon de livraison', 'folder'),

  /// Relevé bancaire
  releveBancaire('Relevé bancaire', 'bank'),

  /// Bulletin de paie
  bulletinPaie('Bulletin de paie', 'work'),

  /// Contrat (travail, bail, prestation)
  contrat('Contrat', 'contract'),

  /// Attestation / Certificat
  attestation('Attestation', 'folder'),

  /// Avis d'imposition
  avisImposition('Avis d\'imposition', 'tax'),

  /// Déclaration fiscale (TVA, IS, IR)
  declarationFiscale('Déclaration fiscale', 'tax'),

  /// Carte d'identité / Passeport
  identite('Pièce d\'identité', 'folder'),

  /// Assurance (police, attestation, sinistre)
  assurance('Assurance', 'insurance'),

  /// Courrier administratif
  courrier('Courrier', 'folder'),

  /// Note de frais
  noteFrais('Note de frais', 'money'),

  /// Document médical / Santé
  sante('Document santé', 'health'),

  /// Document scolaire
  scolarite('Document scolaire', 'school'),

  /// Autre (non classifié)
  autre('Autre', 'folder');

  const DocumentCategory(this.label, this.icon);

  /// Libellé en français
  final String label;

  /// Icône associée
  final String icon;

  /// Trouve la catégorie par son label (insensible à la casse)
  static DocumentCategory fromLabel(String label) {
    final normalized = label.trim().toLowerCase();
    return DocumentCategory.values.firstWhere(
      (c) => c.label.toLowerCase() == normalized || c.name.toLowerCase() == normalized,
      orElse: () => DocumentCategory.autre,
    );
  }
}

/// Résultat de l'analyse IA d'un document
class AiClassificationResult {
  const AiClassificationResult({
    required this.category,
    required this.confidence,
    this.suggestedName,
    this.vendorName,
    this.documentDate,
    this.documentAmount,
    this.documentNumber,
    this.summary,
    this.suggestedFolder,
    this.tags = const [],
  });

  /// Catégorie détectée
  final DocumentCategory category;

  /// Confiance (0.0 à 1.0)
  final double confidence;

  /// Nom de fichier suggéré
  final String? suggestedName;

  /// Nom du fournisseur/émetteur détecté
  final String? vendorName;

  /// Date du document détectée
  final String? documentDate;

  /// Montant détecté
  final double? documentAmount;

  /// Numéro du document (facture, contrat, etc.)
  final String? documentNumber;

  /// Résumé du contenu
  final String? summary;

  /// Dossier suggéré pour le classement
  final String? suggestedFolder;

  /// Tags extraits
  final List<String> tags;

  @override
  String toString() =>
      'AiResult(${category.label}, confiance: ${(confidence * 100).toStringAsFixed(0)}%)';
}
