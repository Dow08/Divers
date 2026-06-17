// ================================================================
// SORTIA — Écran Paramètres
// Profil, préférences, abonnement, actions
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sortia/features/settings/domain/models/user_preferences.dart';
import 'package:sortia/features/settings/presentation/providers/settings_providers.dart';

/// Écran des paramètres
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Profil ────────────────────────────────────
          _ProfileCard(prefs: prefs),
          const SizedBox(height: 20),

          // ── Abonnement ────────────────────────────────
          _PlanCard(prefs: prefs),
          const SizedBox(height: 20),

          // ── Apparence ─────────────────────────────────
          _SectionTitle(title: 'Apparence'),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Thème',
            subtitle: '${prefs.themeMode.emoji} ${prefs.themeMode.label}',
            onTap: () => _showThemeDialog(context, ref),
          ),
          _SettingsTile(
            icon: Icons.view_agenda_outlined,
            title: 'Vue par défaut',
            subtitle: '${prefs.defaultView.emoji} ${prefs.defaultView.label}',
            onTap: () {
              final next = prefs.defaultView == ViewMode.list
                  ? ViewMode.grid
                  : ViewMode.list;
              ref.read(userPreferencesProvider.notifier).updateDefaultView(next);
            },
          ),
          const SizedBox(height: 20),

          // ── Notifications ─────────────────────────────
          _SectionTitle(title: 'Notifications'),
          _SettingsSwitch(
            icon: Icons.notifications_outlined,
            title: 'Notifications push',
            value: prefs.notificationsEnabled,
            onChanged: (v) => ref
                .read(userPreferencesProvider.notifier)
                .toggleNotifications(v),
          ),
          _SettingsSwitch(
            icon: Icons.email_outlined,
            title: 'Notifications email',
            value: prefs.emailNotifications,
            onChanged: (v) => ref
                .read(userPreferencesProvider.notifier)
                .toggleEmailNotifications(v),
          ),
          const SizedBox(height: 20),

          // ── IA ────────────────────────────────────────
          _SectionTitle(title: 'Intelligence artificielle'),
          _SettingsSwitch(
            icon: Icons.auto_awesome_outlined,
            title: 'Classification automatique',
            subtitle: 'Classer les documents dès l\'import',
            value: prefs.autoClassify,
            onChanged: (v) => ref
                .read(userPreferencesProvider.notifier)
                .toggleAutoClassify(v),
          ),
          const SizedBox(height: 20),

          // ── Données ───────────────────────────────────
          _SectionTitle(title: 'Données'),
          _SettingsTile(
            icon: Icons.download_outlined,
            title: 'Exporter mes données',
            subtitle: 'Télécharger tous vos documents',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.delete_outline,
            title: 'Supprimer mon compte',
            subtitle: 'Action irréversible',
            color: const Color(0xFFE74C3C),
            onTap: () {},
          ),
          const SizedBox(height: 20),

          // ── À propos ──────────────────────────────────
          _SectionTitle(title: 'À propos'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'Version',
            subtitle: 'SORTIA v1.0.0',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Politique de confidentialité',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.gavel_outlined,
            title: 'Conditions générales',
            onTap: () {},
          ),
          const SizedBox(height: 20),

          // ── Déconnexion ───────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  ref.read(userPreferencesProvider.notifier).signOut(),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE74C3C),
                side: const BorderSide(color: Color(0xFFE74C3C)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Choisir le thème'),
        children: AppThemeMode.values.map((mode) {
          return SimpleDialogOption(
            onPressed: () {
              ref.read(userPreferencesProvider.notifier).updateTheme(mode);
              Navigator.of(ctx).pop();
            },
            child: Text('${mode.emoji}  ${mode.label}'),
          );
        }).toList(),
      ),
    );
  }
}

// ── Carte Profil ─────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.prefs});
  final UserPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4F72), Color(0xFF2E86C1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4F72).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              _initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prefs.displayName ?? 'Utilisateur',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (prefs.email != null)
                  Text(
                    prefs.email!,
                    style: const TextStyle(
                      color: Color(0xFFAED6F1),
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  String get _initials {
    final name = prefs.displayName ?? prefs.email ?? '?';
    final parts = name.split(RegExp(r'[\s@.]'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

// ── Carte Plan ───────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.prefs});
  final UserPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(prefs.planEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                'Plan ${prefs.planLabel}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              if (prefs.plan == 'free')
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF17A589),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Upgrader',
                      style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.cloud_outlined,
                  size: 16, color: Color(0xFF566573)),
              const SizedBox(width: 6),
              Text(
                prefs.storageFormatted,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF566573),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: prefs.storageRate.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFFEBEEF0),
              valueColor: AlwaysStoppedAnimation<Color>(
                prefs.storageRate > 0.9
                    ? const Color(0xFFE74C3C)
                    : prefs.storageRate > 0.7
                        ? const Color(0xFFE67E22)
                        : const Color(0xFF17A589),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Composants réutilisables ─────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF566573),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: color ?? const Color(0xFF1B4F72), size: 22),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color ?? const Color(0xFF1A1A2E),
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: const TextStyle(fontSize: 12, color: Color(0xFF566573)))
            : null,
        trailing: Icon(Icons.chevron_right,
            size: 20, color: color ?? const Color(0xFFD5D8DC)),
        onTap: onTap,
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SwitchListTile(
        secondary: Icon(icon, color: const Color(0xFF1B4F72), size: 22),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: const TextStyle(fontSize: 12, color: Color(0xFF566573)))
            : null,
        value: value,
        activeColor: const Color(0xFF17A589),
        onChanged: onChanged,
      ),
    );
  }
}
