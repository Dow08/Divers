// ================================================================
// SORTIA — Configuration du routeur GoRouter
// Navigation complète de l'application
// ================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/explorer/presentation/screens/explorer_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/scanner/presentation/screens/scanner_screen.dart';
import '../../features/mail/presentation/screens/mail_screen.dart';
import '../../features/alerts/presentation/screens/alerts_screen.dart';
import '../../features/sharing/presentation/screens/sharing_screen.dart';
import '../../features/vault/presentation/screens/vault_screen.dart';
import '../../features/subscription/presentation/screens/subscription_screen.dart';
import '../../features/signature/presentation/screens/signature_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/onboarding/presentation/screens/template_selection_screen.dart';
import '../../features/explorer/presentation/screens/file_preview_screen.dart';
import '../../features/notes/notes_module.dart';
import '../../features/workflow/workflow_module.dart';
import '../../features/rgpd/rgpd_module.dart';
import '../../features/import_batch/import_module.dart';
import '../../features/archive/archive_module.dart';
import '../navigation/main_shell.dart';
import 'route_guards.dart';
import 'route_names.dart';

/// Routeur principal de l'application
///
/// Utilise GoRouter pour la navigation déclarative.
/// Toutes les routes sont protégées par les guards d'authentification.
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  redirect: RouteGuards.authGuard,
  routes: [
    // ── Routes d'authentification ──
    GoRoute(
      path: '/login',
      name: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: RouteNames.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/cgu',
      name: RouteNames.cgu,
      builder: (context, state) => const CguScreen(),
    ),

    // ── Shell principal (avec BottomNavigationBar) ──
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const MainShell(),
    ),

    // ── Routes principales ──
    GoRoute(
      path: '/explorer',
      name: RouteNames.explorer,
      builder: (context, state) => const ExplorerScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      name: RouteNames.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: RouteNames.settings,
      builder: (context, state) => const SettingsScreen(),
    ),

    // ── Fonctionnalités ──
    GoRoute(
      path: '/search',
      name: RouteNames.search,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/scanner',
      name: RouteNames.scanner,
      builder: (context, state) => const ScannerScreen(),
    ),
    GoRoute(
      path: '/mail',
      name: RouteNames.mail,
      builder: (context, state) => const MailScreen(),
    ),
    GoRoute(
      path: '/alerts',
      name: RouteNames.alerts,
      builder: (context, state) => const AlertsScreen(),
    ),
    GoRoute(
      path: '/sharing',
      name: RouteNames.sharing,
      builder: (context, state) => const SharingScreen(),
    ),
    GoRoute(
      path: '/vault',
      name: RouteNames.vault,
      builder: (context, state) => const VaultScreen(),
    ),
    GoRoute(
      path: '/subscription',
      name: RouteNames.subscription,
      builder: (context, state) => const SubscriptionScreen(),
    ),
    GoRoute(
      path: '/signature',
      name: RouteNames.signature,
      builder: (context, state) => const SignatureScreen(),
    ),

    // ── Onboarding ──
    GoRoute(
      path: '/welcome',
      name: RouteNames.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/template-selection',
      name: RouteNames.templateSelection,
      builder: (context, state) => const TemplateSelectionScreen(),
    ),

    // ── Prévisualisation ──
    GoRoute(
      path: '/file-preview/:fileId',
      name: RouteNames.filePreview,
      builder: (context, state) {
        final fileId = state.pathParameters['fileId']!;
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return FilePreviewScreen(
          fileId: fileId,
          fileName: extra['fileName'] as String? ?? 'Fichier',
          mimeType: extra['mimeType'] as String?,
          fileSize: extra['fileSize'] as int?,
          storagePath: extra['storagePath'] as String?,
          aiCategory: extra['aiCategory'] as String?,
          aiConfidence: extra['aiConfidence'] as double?,
        );
      },
    ),

    // ── Modules complémentaires ──
    GoRoute(
      path: '/notes',
      name: RouteNames.notes,
      builder: (context, state) => const NotesScreen(),
    ),
    GoRoute(
      path: '/workflow',
      name: RouteNames.workflow,
      builder: (context, state) => const WorkflowScreen(),
    ),
    GoRoute(
      path: '/conformite',
      name: RouteNames.conformite,
      builder: (context, state) => const RgpdScreen(),
    ),
    GoRoute(
      path: '/import',
      name: RouteNames.importScreen,
      builder: (context, state) => const ImportScreen(),
    ),
    GoRoute(
      path: '/archive',
      name: RouteNames.archive,
      builder: (context, state) => const ArchiveScreen(),
    ),
  ],
);
