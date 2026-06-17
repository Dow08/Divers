// ================================================================
// SORTIA — Modèle AlertModel
// Alertes et notifications (échéances, RGPD, stockage…)
// ================================================================

/// Priorité d'une alerte
enum AlertPriority {
  low('Basse', '🔵'),
  normal('Normale', '🟡'),
  high('Haute', '🟠'),
  urgent('Urgente', '🔴');

  const AlertPriority(this.label, this.emoji);
  final String label;
  final String emoji;

  static AlertPriority fromString(String value) {
    return AlertPriority.values.firstWhere(
      (p) => p.name == value.toLowerCase(),
      orElse: () => AlertPriority.normal,
    );
  }
}

/// Type d'alerte
enum AlertType {
  deadline('Échéance', '📅'),
  rgpd('RGPD', '🛡️'),
  storage('Stockage', '☁️'),
  expiration('Expiration', '⏱️'),
  renewal('Renouvellement', '🔄'),
  payment('Paiement', '💶'),
  signature('Signature', '✍️'),
  custom('Personnalisée', '🔔');

  const AlertType(this.label, this.emoji);
  final String label;
  final String emoji;

  static AlertType fromString(String value) {
    return AlertType.values.firstWhere(
      (t) => t.name == value.toLowerCase(),
      orElse: () => AlertType.custom,
    );
  }
}

/// Modèle d'une alerte/notification
class AlertModel {
  const AlertModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.message,
    this.relatedFileId,
    this.relatedFolderId,
    required this.triggerAt,
    this.isRead = false,
    this.isDismissed = false,
    this.priority = AlertPriority.normal,
    this.createdAt,
  });

  final String id;
  final String userId;
  final AlertType type;
  final String title;
  final String? message;
  final String? relatedFileId;
  final String? relatedFolderId;
  final DateTime triggerAt;
  final bool isRead;
  final bool isDismissed;
  final AlertPriority priority;
  final DateTime? createdAt;

  /// Vérifie si l'alerte est en retard
  bool get isOverdue => triggerAt.isBefore(DateTime.now());

  /// Vérifie si l'alerte est pour aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return triggerAt.year == now.year &&
        triggerAt.month == now.month &&
        triggerAt.day == now.day;
  }

  /// Vérifie si l'alerte est dans les 7 prochains jours
  bool get isThisWeek {
    final now = DateTime.now();
    final diff = triggerAt.difference(now);
    return diff.inDays >= 0 && diff.inDays <= 7;
  }

  /// Temps restant formaté
  String get timeRemainingFormatted {
    final diff = triggerAt.difference(DateTime.now());
    if (diff.isNegative) {
      if (diff.inDays.abs() == 0) return "Aujourd'hui";
      return 'En retard de ${diff.inDays.abs()}j';
    }
    if (diff.inDays == 0) return "Aujourd'hui";
    if (diff.inDays == 1) return 'Demain';
    if (diff.inDays < 7) return 'Dans ${diff.inDays}j';
    if (diff.inDays < 30) return 'Dans ${(diff.inDays / 7).floor()} sem.';
    return 'Dans ${(diff.inDays / 30).floor()} mois';
  }

  /// Date formatée (ex: "15 jan 2026")
  String get dateFormatted {
    const months = [
      '', 'jan', 'fév', 'mar', 'avr', 'mai', 'jun',
      'jul', 'aoû', 'sep', 'oct', 'nov', 'déc',
    ];
    return '${triggerAt.day} ${months[triggerAt.month]} ${triggerAt.year}';
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        type: AlertType.fromString(json['type'] as String),
        title: json['title'] as String,
        message: json['message'] as String?,
        relatedFileId: json['related_file_id'] as String?,
        relatedFolderId: json['related_folder_id'] as String?,
        triggerAt: DateTime.parse(json['trigger_at'] as String),
        isRead: (json['is_read'] as bool?) ?? false,
        isDismissed: (json['is_dismissed'] as bool?) ?? false,
        priority:
            AlertPriority.fromString((json['priority'] as String?) ?? 'normal'),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'type': type.name,
        'title': title,
        'message': message,
        'related_file_id': relatedFileId,
        'related_folder_id': relatedFolderId,
        'trigger_at': triggerAt.toIso8601String(),
        'is_read': isRead,
        'is_dismissed': isDismissed,
        'priority': priority.name,
      };

  AlertModel copyWith({
    bool? isRead,
    bool? isDismissed,
  }) {
    return AlertModel(
      id: id,
      userId: userId,
      type: type,
      title: title,
      message: message,
      relatedFileId: relatedFileId,
      relatedFolderId: relatedFolderId,
      triggerAt: triggerAt,
      isRead: isRead ?? this.isRead,
      isDismissed: isDismissed ?? this.isDismissed,
      priority: priority,
      createdAt: createdAt,
    );
  }

  @override
  String toString() =>
      'Alert(${priority.emoji} $title — ${timeRemainingFormatted})';
}
