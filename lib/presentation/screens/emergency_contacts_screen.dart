import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_constants.dart';
import '../../config/app_strings.dart';
import '../../domain/entities/emergency_contact.dart';
import '../../presentation/providers/emergency_contact_provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/widgets/app_dialogs.dart';
import '../../presentation/widgets/app_snackbar.dart';
import '../../utils/validators.dart';

class EmergencyContactsScreen extends ConsumerStatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  ConsumerState<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState
    extends ConsumerState<EmergencyContactsScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text(AppStrings.unauthorized)),
      );
    }

    final contactsAsync = ref.watch(
      emergencyContactsProvider(currentUser.userId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.emergencyContacts),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddContactDialog(context, ref, currentUser.userId);
            },
          ),
        ],
      ),
      body: contactsAsync.when(
        data: (contacts) {
          if (contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.contacts_outlined, size: 64),
                  const SizedBox(height: AppSpacing.md),
                  const Text(AppStrings.addContact),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddContactDialog(context, ref, currentUser.userId);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text(AppStrings.addContact),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ContactListTile(
                contact: contact,
                onEdit: () {
                  _showEditContactDialog(context, ref, contact);
                },
                onDelete: () {
                  _showDeleteConfirmDialog(context, ref, contact.contactId);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  void _showAddContactDialog(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddContactDialog(
        userId: userId,
        onAdd: (contact) {
          Navigator.pop(context);
          AppSnackBar.show(
            context,
            message: AppStrings.contactAddedSuccess,
            type: SnackBarType.success,
          );
        },
      ),
    );
  }

  void _showEditContactDialog(
    BuildContext context,
    WidgetRef ref,
    EmergencyContact contact,
  ) {
    showDialog(
      context: context,
      builder: (context) => EditContactDialog(
        contact: contact,
        onUpdate: () {
          Navigator.pop(context);
          AppSnackBar.show(
            context,
            message: AppStrings.contactUpdatedSuccess,
            type: SnackBarType.success,
          );
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    String contactId,
  ) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: AppStrings.deleteContact,
        message: 'Are you sure you want to delete this contact?',
        confirmText: AppStrings.delete,
        cancelText: AppStrings.cancel,
        isDangerous: true,
        onConfirm: () async {
          final notifier = ref.read(emergencyContactNotifierProvider.notifier);
          await notifier.deleteContact(contactId);
          if (context.mounted) {
            AppSnackBar.show(
              context,
              message: AppStrings.contactDeletedSuccess,
              type: SnackBarType.success,
            );
          }
        },
      ),
    );
  }
}

class ContactListTile extends StatelessWidget {
  final EmergencyContact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ContactListTile({
    super.key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(contact.name[0].toUpperCase()),
        ),
        title: Text(contact.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contact.phone),
            Text(
              contact.relationship,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: onEdit,
              child: const Text(AppStrings.edit),
            ),
            PopupMenuItem(
              onTap: onDelete,
              child: const Text(AppStrings.delete),
            ),
          ],
        ),
      ),
    );
  }
}

class AddContactDialog extends ConsumerStatefulWidget {
  final String userId;
  final Function(EmergencyContact) onAdd;

  const AddContactDialog({
    super.key,
    required this.userId,
    required this.onAdd,
  });

  @override
  ConsumerState<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends ConsumerState<AddContactDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _relationshipController;
  bool _isPrimary = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _relationshipController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final notifier = ref.read(emergencyContactNotifierProvider.notifier);
      await notifier.addContact(
        userId: widget.userId,
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        relationship: _relationshipController.text,
        isPrimary: _isPrimary,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onAdd(EmergencyContact(
          contactId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          userId: widget.userId,
          name: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          relationship: _relationshipController.text,
          isPrimary: _isPrimary,
          createdAt: DateTime.now(),
          updatedAt: null,
        ));
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Failed to add contact: $e',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.addContact),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: AppStrings.name),
                validator: AppValidator.validateName,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: AppStrings.phone),
                validator: AppValidator.validatePhone,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: AppStrings.email),
                validator: AppValidator.validateEmail,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _relationshipController,
                decoration:
                    const InputDecoration(labelText: AppStrings.relationship),
                validator: (value) => AppValidator.validateNotEmpty(
                    value, AppStrings.relationship),
              ),
              const SizedBox(height: AppSpacing.md),
              CheckboxListTile(
                title: const Text(AppStrings.primary),
                value: _isPrimary,
                onChanged: (value) {
                  setState(() => _isPrimary = value ?? false);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}

class EditContactDialog extends ConsumerStatefulWidget {
  final EmergencyContact contact;
  final VoidCallback onUpdate;

  const EditContactDialog({
    super.key,
    required this.contact,
    required this.onUpdate,
  });

  @override
  ConsumerState<EditContactDialog> createState() => _EditContactDialogState();
}

class _EditContactDialogState extends ConsumerState<EditContactDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _relationshipController;
  late bool _isPrimary;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact.name);
    _phoneController = TextEditingController(text: widget.contact.phone);
    _emailController = TextEditingController(text: widget.contact.email);
    _relationshipController =
        TextEditingController(text: widget.contact.relationship);
    _isPrimary = widget.contact.isPrimary;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final notifier = ref.read(emergencyContactNotifierProvider.notifier);
      await notifier.updateContact(
        contactId: widget.contact.contactId,
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        relationship: _relationshipController.text,
        isPrimary: _isPrimary,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onUpdate();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Failed to update contact: $e',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.editContact),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: AppStrings.name),
                validator: AppValidator.validateName,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: AppStrings.phone),
                validator: AppValidator.validatePhone,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: AppStrings.email),
                validator: AppValidator.validateEmail,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _relationshipController,
                decoration:
                    const InputDecoration(labelText: AppStrings.relationship),
                validator: (value) => AppValidator.validateNotEmpty(
                    value, AppStrings.relationship),
              ),
              const SizedBox(height: AppSpacing.md),
              CheckboxListTile(
                title: const Text(AppStrings.primary),
                value: _isPrimary,
                onChanged: (value) {
                  setState(() => _isPrimary = value ?? false);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}
