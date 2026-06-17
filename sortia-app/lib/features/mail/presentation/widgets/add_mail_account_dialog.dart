// ================================================================
// SORTIA — Dialog Ajout Compte Email
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sortia/features/mail/domain/models/mail_account_model.dart';
import 'package:sortia/features/mail/presentation/providers/mail_providers.dart';

/// Dialog pour ajouter un nouveau compte email
class AddMailAccountDialog extends ConsumerStatefulWidget {
  const AddMailAccountDialog({super.key});

  @override
  ConsumerState<AddMailAccountDialog> createState() =>
      _AddMailAccountDialogState();
}

class _AddMailAccountDialogState extends ConsumerState<AddMailAccountDialog> {
  MailProvider _selectedProvider = MailProvider.gmail;
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _imapHostController = TextEditingController();
  final _imapPortController = TextEditingController(text: '993');
  bool _isPersonal = false;
  bool _isProfessional = true;
  bool _imapUseSsl = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _displayNameController.dispose();
    _imapHostController.dispose();
    _imapPortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              const Row(
                children: [
                  Icon(Icons.email_outlined, color: Color(0xFF1B4F72)),
                  SizedBox(width: 8),
                  Text(
                    'Ajouter un compte email',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sélection provider
              const Text(
                'Fournisseur',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF566573),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: MailProvider.values.map((provider) {
                  final isSelected = _selectedProvider == provider;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedProvider = provider),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1B4F72)
                              : const Color(0xFFF4F6F7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1B4F72)
                                : const Color(0xFFD5D8DC),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              provider.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              provider.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF566573),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Email
              _buildTextField(
                controller: _emailController,
                label: 'Adresse email',
                hint: 'you@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // Nom d'affichage
              _buildTextField(
                controller: _displayNameController,
                label: 'Nom d\'affichage (optionnel)',
                hint: 'Mon email pro',
                icon: Icons.label_outlined,
              ),
              const SizedBox(height: 12),

              // IMAP fields
              if (_selectedProvider == MailProvider.imap) ...[
                _buildTextField(
                  controller: _imapHostController,
                  label: 'Serveur IMAP',
                  hint: 'imap.example.com',
                  icon: Icons.dns_outlined,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _imapPortController,
                        label: 'Port',
                        hint: '993',
                        icon: Icons.numbers,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        const Text('SSL',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF566573))),
                        Switch(
                          value: _imapUseSsl,
                          activeColor: const Color(0xFF17A589),
                          onChanged: (v) =>
                              setState(() => _imapUseSsl = v),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Type de compte
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Personnel',
                          style: TextStyle(fontSize: 13)),
                      value: _isPersonal,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (v) =>
                          setState(() => _isPersonal = v ?? false),
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Professionnel',
                          style: TextStyle(fontSize: 13)),
                      value: _isProfessional,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (v) =>
                          setState(() => _isProfessional = v ?? true),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Boutons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B4F72),
                      foregroundColor: Colors.white,
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check, size: 18),
                    label: Text(_selectedProvider == MailProvider.imap
                        ? 'Connecter'
                        : 'Autoriser ${_selectedProvider.label}'),
                  ),
                ],
              ),

              // Info OAuth
              if (_selectedProvider != MailProvider.imap) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF2E86C1).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: Color(0xFF2E86C1)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Vous serez redirigé vers ${_selectedProvider.label} '
                          'pour autoriser SORTIA à lire vos emails.',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF566573),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Pour Gmail/Outlook, lancer le flux OAuth ici
      // Pour l'instant, on crée le compte en BDD
      final account = MailAccount(
        id: '', // auto-generated by Supabase
        userId: '', // set by repository
        provider: _selectedProvider,
        emailAddress: email,
        displayName: _displayNameController.text.trim().isEmpty
            ? null
            : _displayNameController.text.trim(),
        isPersonal: _isPersonal,
        isProfessional: _isProfessional,
        imapHost: _selectedProvider == MailProvider.imap
            ? _imapHostController.text.trim()
            : null,
        imapPort: _selectedProvider == MailProvider.imap
            ? int.tryParse(_imapPortController.text)
            : null,
        imapUseSsl: _imapUseSsl,
      );

      await ref.read(mailAccountsProvider.notifier).addAccount(account);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
