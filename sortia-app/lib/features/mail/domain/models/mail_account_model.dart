// ================================================================
// SORTIA — Modèle MailAccount
// Représente un compte email connecté (Gmail, Outlook, IMAP)
// ================================================================

/// Fournisseur email supporté
enum MailProvider {
  gmail('Gmail', '📧'),
  outlook('Outlook', '📬'),
  imap('IMAP', '📩');

  const MailProvider(this.label, this.emoji);
  final String label;
  final String emoji;

  static MailProvider fromString(String value) {
    return MailProvider.values.firstWhere(
      (p) => p.name == value.toLowerCase(),
      orElse: () => MailProvider.imap,
    );
  }
}

/// Statut de synchronisation
enum SyncStatus {
  idle('En attente'),
  syncing('Synchronisation...'),
  success('Synchronisé'),
  error('Erreur');

  const SyncStatus(this.label);
  final String label;
}

/// Modèle d'un compte email connecté
class MailAccount {
  const MailAccount({
    required this.id,
    required this.userId,
    required this.provider,
    required this.emailAddress,
    this.displayName,
    this.isPersonal = false,
    this.isProfessional = true,
    this.oauthToken,
    this.oauthRefresh,
    this.imapHost,
    this.imapPort,
    this.imapUseSsl = true,
    this.lastSyncAt,
    this.syncEnabled = true,
    this.foldersWatched = const ['INBOX'],
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String userId;
  final MailProvider provider;
  final String emailAddress;
  final String? displayName;
  final bool isPersonal;
  final bool isProfessional;
  final String? oauthToken;
  final String? oauthRefresh;
  final String? imapHost;
  final int? imapPort;
  final bool imapUseSsl;
  final DateTime? lastSyncAt;
  final bool syncEnabled;
  final List<String> foldersWatched;
  final bool isActive;
  final DateTime? createdAt;

  /// Nom d'affichage (displayName ou email)
  String get label => displayName ?? emailAddress;

  /// Type de compte (Personnel ou Professionnel)
  String get accountType {
    if (isPersonal && isProfessional) return 'Mixte';
    if (isPersonal) return 'Personnel';
    return 'Professionnel';
  }

  /// Vérifie si le compte a un token OAuth valide
  bool get hasOAuth => oauthToken != null && oauthToken!.isNotEmpty;

  /// Vérifie si le compte est IMAP avec config complète
  bool get hasImapConfig =>
      provider == MailProvider.imap &&
      imapHost != null &&
      imapHost!.isNotEmpty &&
      imapPort != null;

  /// Temps écoulé depuis la dernière sync
  String get lastSyncFormatted {
    if (lastSyncAt == null) return 'Jamais synchronisé';
    final diff = DateTime.now().difference(lastSyncAt!);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    return 'il y a ${diff.inDays}j';
  }

  factory MailAccount.fromJson(Map<String, dynamic> json) => MailAccount(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        provider: MailProvider.fromString(json['provider'] as String),
        emailAddress: json['email_address'] as String,
        displayName: json['display_name'] as String?,
        isPersonal: (json['is_personal'] as bool?) ?? false,
        isProfessional: (json['is_professional'] as bool?) ?? true,
        oauthToken: json['oauth_token'] as String?,
        oauthRefresh: json['oauth_refresh'] as String?,
        imapHost: json['imap_host'] as String?,
        imapPort: json['imap_port'] as int?,
        imapUseSsl: (json['imap_use_ssl'] as bool?) ?? true,
        lastSyncAt: json['last_sync_at'] != null
            ? DateTime.parse(json['last_sync_at'] as String)
            : null,
        syncEnabled: (json['sync_enabled'] as bool?) ?? true,
        foldersWatched: (json['folders_watched'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const ['INBOX'],
        isActive: (json['is_active'] as bool?) ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'provider': provider.name,
        'email_address': emailAddress,
        'display_name': displayName,
        'is_personal': isPersonal,
        'is_professional': isProfessional,
        'oauth_token': oauthToken,
        'oauth_refresh': oauthRefresh,
        'imap_host': imapHost,
        'imap_port': imapPort,
        'imap_use_ssl': imapUseSsl,
        'sync_enabled': syncEnabled,
        'folders_watched': foldersWatched,
        'is_active': isActive,
      };

  MailAccount copyWith({
    String? displayName,
    bool? isPersonal,
    bool? isProfessional,
    String? oauthToken,
    String? oauthRefresh,
    String? imapHost,
    int? imapPort,
    bool? imapUseSsl,
    DateTime? lastSyncAt,
    bool? syncEnabled,
    List<String>? foldersWatched,
    bool? isActive,
  }) {
    return MailAccount(
      id: id,
      userId: userId,
      provider: provider,
      emailAddress: emailAddress,
      displayName: displayName ?? this.displayName,
      isPersonal: isPersonal ?? this.isPersonal,
      isProfessional: isProfessional ?? this.isProfessional,
      oauthToken: oauthToken ?? this.oauthToken,
      oauthRefresh: oauthRefresh ?? this.oauthRefresh,
      imapHost: imapHost ?? this.imapHost,
      imapPort: imapPort ?? this.imapPort,
      imapUseSsl: imapUseSsl ?? this.imapUseSsl,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      foldersWatched: foldersWatched ?? this.foldersWatched,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  @override
  String toString() =>
      'MailAccount(${provider.label}: $emailAddress, sync: $syncEnabled)';
}

/// État de la liste des comptes email
class MailState {
  const MailState({
    this.accounts = const [],
    this.isLoading = false,
    this.error,
    this.syncingAccountId,
  });

  final List<MailAccount> accounts;
  final bool isLoading;
  final String? error;
  final String? syncingAccountId;

  /// Nombre de comptes actifs
  int get activeCount => accounts.where((a) => a.isActive).length;

  /// Comptes Gmail connectés
  List<MailAccount> get gmailAccounts =>
      accounts.where((a) => a.provider == MailProvider.gmail).toList();

  /// Comptes Outlook connectés
  List<MailAccount> get outlookAccounts =>
      accounts.where((a) => a.provider == MailProvider.outlook).toList();

  MailState copyWith({
    List<MailAccount>? accounts,
    bool? isLoading,
    String? error,
    String? syncingAccountId,
  }) {
    return MailState(
      accounts: accounts ?? this.accounts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      syncingAccountId: syncingAccountId,
    );
  }
}
