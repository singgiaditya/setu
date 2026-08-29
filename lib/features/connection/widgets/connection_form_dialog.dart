import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import '../../../core/ssh/ssh_config.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../providers/ssh_provider.dart';

class ConnectionFormDialog extends ConsumerStatefulWidget {
  final ConnectionProfile? existingProfile;

  const ConnectionFormDialog({super.key, this.existingProfile});

  @override
  ConsumerState<ConnectionFormDialog> createState() => _ConnectionFormDialogState();
}

class _ConnectionFormDialogState extends ConsumerState<ConnectionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _usernameController;
  late TextEditingController _privateKeyController;
  late TextEditingController _passwordController;
  AuthMethod _authMethod = AuthMethod.privateKey;
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProfile;
    _nameController = TextEditingController(text: p?.name ?? '');
    _hostController = TextEditingController(text: p?.host ?? '');
    _portController = TextEditingController(text: (p?.port ?? 22).toString());
    _usernameController = TextEditingController(text: p?.username ?? '');
    _privateKeyController = TextEditingController();
    _passwordController = TextEditingController();
    _authMethod = p?.authMethod ?? AuthMethod.privateKey;

    _loadExistingCredentials();
  }

  Future<void> _loadExistingCredentials() async {
    if (widget.existingProfile != null) {
      final keyManager = ref.read(sshKeyManagerProvider);
      final id = widget.existingProfile!.id;
      final key = await keyManager.getKey(id);
      if (key != null) _privateKeyController.text = key;
      final pass = await keyManager.getPassword(id);
      if (pass != null) _passwordController.text = pass;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _privateKeyController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final sshService = ref.read(sshServiceProvider);
    final tempProfile = ConnectionProfile(
      id: 'test-temp',
      name: _nameController.text.trim(),
      host: _hostController.text.trim(),
      port: int.tryParse(_portController.text.trim()) ?? 22,
      username: _usernameController.text.trim(),
      authMethod: _authMethod,
      createdAt: DateTime.now(),
    );

    final keyCred = _privateKeyController.text.trim();
    final passCred = _passwordController.text.trim();
    final result = await sshService.connect(
      tempProfile,
      privateKey: _authMethod == AuthMethod.privateKey ? keyCred : null,
      password: _authMethod == AuthMethod.password ? passCred : null,
      timeout: const Duration(seconds: 8),
    );

    if (mounted) {
      setState(() {
        _isTesting = false;
        _testSuccess = result.isSuccess;
        _testResult = result.isSuccess
            ? 'Connection successful! Host reached.'
            : (result.error ?? 'Connection failed');
      });
      if (result.isSuccess) {
        await sshService.disconnect();
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final id = widget.existingProfile?.id ?? const Uuid().v4();
    final profile = ConnectionProfile(
      id: id,
      name: _nameController.text.trim(),
      host: _hostController.text.trim(),
      port: int.tryParse(_portController.text.trim()) ?? 22,
      username: _usernameController.text.trim(),
      authMethod: _authMethod,
      createdAt: widget.existingProfile?.createdAt ?? DateTime.now(),
    );

    final keyManager = ref.read(sshKeyManagerProvider);
    final keyCred = _privateKeyController.text.trim();
    final passCred = _passwordController.text.trim();
    if (_authMethod == AuthMethod.privateKey) {
      if (keyCred.isNotEmpty) await keyManager.saveKey(id, keyCred);
    } else {
      if (passCred.isNotEmpty) await keyManager.savePassword(id, passCred);
    }

    final notifier = ref.read(connectionProfilesProvider.notifier);
    if (widget.existingProfile != null) {
      await notifier.updateProfile(profile);
    } else {
      await notifier.addProfile(profile);
    }

    if (mounted) {
      Navigator.of(context).pop(profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(setuColorsProvider);
    final typography = ref.watch(setuTypographyProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.existingProfile != null ? 'Edit Workstation' : 'Connect Your Machine',
                    style: typography.headlineSmall,
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: colors.foregroundMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Gap(16),

              // Machine Name
              TextFormField(
                controller: _nameController,
                style: typography.bodyMedium,
                decoration: const InputDecoration(
                  labelText: 'Machine Name',
                  hintText: 'e.g. Home Server, Office PC',
                  prefixIcon: Icon(Icons.laptop_chromebook_rounded, size: 20),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Please enter a name' : null,
              ),
              const Gap(12),

              // Host & Port Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _hostController,
                      style: typography.bodyMedium,
                      decoration: const InputDecoration(
                        labelText: 'Tailscale Host or IP',
                        hintText: 'e.g. 100.x.x.x or hostname',
                        prefixIcon: Icon(Icons.dns_rounded, size: 20),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Host is required' : null,
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _portController,
                      keyboardType: TextInputType.number,
                      style: typography.bodyMedium,
                      decoration: const InputDecoration(
                        labelText: 'Port',
                        hintText: '22',
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Port required' : null,
                    ),
                  ),
                ],
              ),
              const Gap(12),

              // Username
              TextFormField(
                controller: _usernameController,
                style: typography.bodyMedium,
                decoration: const InputDecoration(
                  labelText: 'SSH Username',
                  hintText: 'e.g. ubuntu, root, arch',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Username is required' : null,
              ),
              const Gap(14),

              // Auth Method Selector
              Text('Authentication Method', style: typography.labelMedium),
              const Gap(8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.key_rounded, size: 16),
                          Gap(6),
                          Text('SSH Key'),
                        ],
                      ),
                      selected: _authMethod == AuthMethod.privateKey,
                      onSelected: (selected) {
                        if (selected) setState(() => _authMethod = AuthMethod.privateKey);
                      },
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: ChoiceChip(
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.password_rounded, size: 16),
                          Gap(6),
                          Text('Password'),
                        ],
                      ),
                      selected: _authMethod == AuthMethod.password,
                      onSelected: (selected) {
                        if (selected) setState(() => _authMethod = AuthMethod.password);
                      },
                    ),
                  ),
                ],
              ),
              const Gap(14),

              // Private Key PEM or Password input (Separate fields with independent state)
              if (_authMethod == AuthMethod.privateKey)
                TextFormField(
                  key: const ValueKey('privateKeyField'),
                  controller: _privateKeyController,
                  style: typography.code,
                  obscureText: false,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Private Key (PEM format)',
                    hintText: '-----BEGIN OPENSSH PRIVATE KEY-----\n...\n-----END OPENSSH PRIVATE KEY-----',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) {
                    if (widget.existingProfile == null && (v == null || v.isEmpty)) {
                      return 'Please enter or paste your private key';
                    }
                    return null;
                  },
                )
              else
                TextFormField(
                  key: const ValueKey('passwordField'),
                  controller: _passwordController,
                  style: typography.bodyMedium,
                  obscureText: true,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    labelText: 'SSH Password',
                    hintText: 'Enter workstation password',
                  ),
                  validator: (v) {
                    if (widget.existingProfile == null && (v == null || v.isEmpty)) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              const Gap(16),

              // Test Result Box
              if (_testResult != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _testSuccess
                        ? colors.success.withValues(alpha: 0.12)
                        : colors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _testSuccess ? colors.success : colors.error,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _testSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                        color: _testSuccess ? colors.success : colors.error,
                        size: 20,
                      ),
                      const Gap(10),
                      Expanded(
                        child: Text(
                          _testResult!,
                          style: typography.bodySmall.copyWith(
                            color: _testSuccess ? colors.success : colors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
              ],

              // Actions Row
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _isTesting ? null : _testConnection,
                    icon: _isTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.network_ping_rounded, size: 18),
                    label: Text(_isTesting ? 'Testing...' : 'Test'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        widget.existingProfile != null ? 'Save Changes' : 'Save & Connect',
                        style: typography.labelLarge.copyWith(
                          color: const Color(0xFF0D1117),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
