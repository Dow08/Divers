// ================================================================
// SORTIA — Templates d'onboarding
// Arborescences de dossiers prédéfinies
// ================================================================

/// Définition d'un dossier template
class TemplateFolderDef {
  const TemplateFolderDef({
    required this.name,
    this.color = '#1B4F72',
    this.icon = 'folder',
    this.children = const [],
  });

  final String name;
  final String color;
  final String icon;
  final List<TemplateFolderDef> children;
}

/// Templates d'arborescence disponibles
class OnboardingTemplates {
  OnboardingTemplates._();

  /// Tous les templates disponibles
  static const List<TemplateInfo> all = [
    TemplateInfo(
      id: 'tpe',
      name: 'TPE / PME',
      description: 'Structure pour petites entreprises',
      icon: 'work',
    ),
    TemplateInfo(
      id: 'auto',
      name: 'Auto-entrepreneur',
      description: 'Structure simplifiée micro-entreprise',
      icon: 'work',
    ),
    TemplateInfo(
      id: 'famille',
      name: 'Famille',
      description: 'Documents personnels et familiaux',
      icon: 'home',
    ),
    TemplateInfo(
      id: 'immobilier',
      name: 'Immobilier',
      description: 'Gestion de biens immobiliers',
      icon: 'home',
    ),
    TemplateInfo(
      id: 'vierge',
      name: 'Vierge',
      description: 'Commencez avec un espace vide',
      icon: 'folder',
    ),
  ];

  /// Arborescence du template TPE
  static const tpe = [
    TemplateFolderDef(
      name: 'Comptabilité',
      color: '#1B4F72',
      icon: 'money',
      children: [
        TemplateFolderDef(name: 'Factures émises', color: '#1B4F72', icon: 'money'),
        TemplateFolderDef(name: 'Factures fournisseurs', color: '#1B4F72', icon: 'money'),
        TemplateFolderDef(name: 'Notes de frais', color: '#1B4F72', icon: 'money'),
        TemplateFolderDef(name: 'Relevés bancaires', color: '#1B4F72', icon: 'bank'),
        TemplateFolderDef(name: 'TVA', color: '#1B4F72', icon: 'tax'),
      ],
    ),
    TemplateFolderDef(
      name: 'Juridique',
      color: '#6C3483',
      icon: 'legal',
      children: [
        TemplateFolderDef(name: 'Statuts', color: '#6C3483', icon: 'legal'),
        TemplateFolderDef(name: 'Contrats', color: '#6C3483', icon: 'contract'),
        TemplateFolderDef(name: 'PV Assemblées', color: '#6C3483', icon: 'legal'),
      ],
    ),
    TemplateFolderDef(
      name: 'RH & Social',
      color: '#117A65',
      icon: 'work',
      children: [
        TemplateFolderDef(name: 'Bulletins de paie', color: '#117A65', icon: 'money'),
        TemplateFolderDef(name: 'Contrats de travail', color: '#117A65', icon: 'contract'),
        TemplateFolderDef(name: 'URSSAF & Déclarations', color: '#117A65', icon: 'tax'),
      ],
    ),
    TemplateFolderDef(
      name: 'Fiscal',
      color: '#B7950B',
      icon: 'tax',
      children: [
        TemplateFolderDef(name: 'Déclarations fiscales', color: '#B7950B', icon: 'tax'),
        TemplateFolderDef(name: 'Avis d\'imposition', color: '#B7950B', icon: 'tax'),
        TemplateFolderDef(name: 'CFE', color: '#B7950B', icon: 'tax'),
      ],
    ),
    TemplateFolderDef(
      name: 'Assurances',
      color: '#A93226',
      icon: 'insurance',
      children: [
        TemplateFolderDef(name: 'RC Pro', color: '#A93226', icon: 'insurance'),
        TemplateFolderDef(name: 'Locaux', color: '#A93226', icon: 'insurance'),
        TemplateFolderDef(name: 'Véhicules', color: '#A93226', icon: 'car'),
      ],
    ),
  ];

  /// Arborescence du template Auto-entrepreneur
  static const auto = [
    TemplateFolderDef(
      name: 'Factures',
      color: '#1B4F72',
      icon: 'money',
      children: [
        TemplateFolderDef(name: 'Émises', color: '#1B4F72', icon: 'money'),
        TemplateFolderDef(name: 'Reçues', color: '#1B4F72', icon: 'money'),
      ],
    ),
    TemplateFolderDef(name: 'URSSAF', color: '#117A65', icon: 'tax'),
    TemplateFolderDef(name: 'Impôts', color: '#B7950B', icon: 'tax'),
    TemplateFolderDef(name: 'Banque', color: '#2874A6', icon: 'bank'),
    TemplateFolderDef(name: 'Assurance RC Pro', color: '#A93226', icon: 'insurance'),
  ];

  /// Arborescence du template Famille
  static const famille = [
    TemplateFolderDef(
      name: 'Identité',
      color: '#1B4F72',
      icon: 'folder',
      children: [
        TemplateFolderDef(name: 'CNI / Passeports', color: '#1B4F72'),
        TemplateFolderDef(name: 'Livret de famille', color: '#1B4F72'),
        TemplateFolderDef(name: 'Actes de naissance', color: '#1B4F72'),
      ],
    ),
    TemplateFolderDef(name: 'Logement', color: '#117A65', icon: 'home'),
    TemplateFolderDef(name: 'Santé', color: '#A93226', icon: 'health'),
    TemplateFolderDef(name: 'Banque', color: '#2874A6', icon: 'bank'),
    TemplateFolderDef(name: 'Impôts', color: '#B7950B', icon: 'tax'),
    TemplateFolderDef(name: 'Assurances', color: '#6C3483', icon: 'insurance'),
    TemplateFolderDef(name: 'Scolarité', color: '#D4AC0D', icon: 'school'),
    TemplateFolderDef(name: 'Véhicules', color: '#616161', icon: 'car'),
  ];

  /// Arborescence du template Immobilier
  static const immobilier = [
    TemplateFolderDef(
      name: 'Bien 1',
      color: '#1B4F72',
      icon: 'home',
      children: [
        TemplateFolderDef(name: 'Acte de vente', color: '#1B4F72', icon: 'contract'),
        TemplateFolderDef(name: 'Bail / Locataire', color: '#1B4F72', icon: 'contract'),
        TemplateFolderDef(name: 'Charges / Copropriété', color: '#1B4F72', icon: 'money'),
        TemplateFolderDef(name: 'Travaux', color: '#1B4F72', icon: 'folder'),
        TemplateFolderDef(name: 'Assurance', color: '#1B4F72', icon: 'insurance'),
        TemplateFolderDef(name: 'Diagnostics', color: '#1B4F72', icon: 'folder'),
      ],
    ),
    TemplateFolderDef(name: 'Fiscalité immobilière', color: '#B7950B', icon: 'tax'),
    TemplateFolderDef(name: 'Prêts immobiliers', color: '#A93226', icon: 'bank'),
  ];

  /// Retourne l'arborescence pour un template donné
  static List<TemplateFolderDef> getTemplate(String templateId) {
    switch (templateId) {
      case 'tpe':
        return tpe;
      case 'auto':
        return auto;
      case 'famille':
        return famille;
      case 'immobilier':
        return immobilier;
      case 'vierge':
        return const [];
      default:
        return const [];
    }
  }
}

/// Informations sur un template
class TemplateInfo {
  const TemplateInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final String icon;
}
