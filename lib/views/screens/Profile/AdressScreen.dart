import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Config/app_colors.dart';
import '../../../Models/adress.dart';
import '../../../providers/adress_provider.dart';

class AdressScreen extends StatefulWidget {
  const AdressScreen({super.key});

  @override
  State<AdressScreen> createState() => _AdressScreenState();
}

class _AdressScreenState extends State<AdressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      context.read<AdressProvider>().listenAdresses(userId);
    });
  }

  Future<void> _addOrEditAdress({Adressmodel? current}) async {
    final rootContext = context;
    final provider = context.read<AdressProvider>();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final result = await _openAdressForm(current: current);
    if (!mounted) return;
    if (result == null) return;

    try {
      if (current == null) {
        await provider.addAdress(userId: userId, adress: result);
      } else {
        await provider.updateAdress(userId: userId, adress: result);
      }

      if (result.isDefault) {
        await provider.setDefaultAdress(userId: userId, adressId: result.id);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        rootContext,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<Adressmodel?> _openAdressForm({Adressmodel? current}) async {
    final provider = context.read<AdressProvider>();
    return showModalBottomSheet<Adressmodel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _AdressFormSheet(
        current: current,
        generatedId: current?.id ?? provider.generateAdressId(),
      ),
    );
  }

  Future<void> _deleteAdress(Adressmodel adress) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer adresse'),
        content: Text('Supprimer ${adress.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;
    try {
      await context.read<AdressProvider>().deleteAdress(
        userId: userId,
        adressId: adress.id,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur suppression: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final provider = context.watch<AdressProvider>();

    if (firebaseUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF3F0EC),
        body: Center(child: Text('Connectez-vous pour gerer vos adresses.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0EC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.brown.withOpacity(0.15)),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.primary,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Adresses sauvegardees',
                      style: TextStyle(
                        fontSize: 36 / 2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.isLoading && provider.adresses.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      children: [
                        if (provider.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              provider.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ...provider.adresses.map(
                          (adress) => _AdressCard(
                            adress: adress,
                            onEdit: () => _addOrEditAdress(current: adress),
                            onDelete: () => _deleteAdress(adress),
                            onMakeDefault: adress.isDefault
                                ? null
                                : () => context
                                      .read<AdressProvider>()
                                      .setDefaultAdress(
                                        userId: firebaseUser.uid,
                                        adressId: adress.id,
                                      ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: Colors.brown.withOpacity(0.2),
                            ),
                            backgroundColor: const Color(0xFFF0ECE5),
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _addOrEditAdress,
                          icon: const Icon(Icons.add),
                          label: const Text(
                            'Ajouter une nouvelle adresse',
                            style: TextStyle(
                              fontSize: 22 / 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdressFormSheet extends StatefulWidget {
  final Adressmodel? current;
  final String generatedId;

  const _AdressFormSheet({required this.current, required this.generatedId});

  @override
  State<_AdressFormSheet> createState() => _AdressFormSheetState();
}

class _AdressFormSheetState extends State<_AdressFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _streetController;
  late final TextEditingController _postalController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _phoneController;
  late bool _isDefault;
  bool _showRequiredErrors = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.current?.name ?? '');
    _streetController = TextEditingController(
      text: widget.current?.street ?? '',
    );
    _postalController = TextEditingController(
      text: widget.current?.postalCode ?? '',
    );
    _cityController = TextEditingController(text: widget.current?.city ?? '');
    _countryController = TextEditingController(
      text: widget.current?.country ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.current?.phoneNumber ?? '',
    );
    _isDefault = widget.current?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _postalController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _requiredError(String value) {
    if (!_showRequiredErrors) return null;
    return value.trim().isEmpty ? 'Champ obligatoire' : null;
  }

  void _submit() {
    final name = _nameController.text.trim();
    final street = _streetController.text.trim();
    final postalCode = _postalController.text.trim();
    final city = _cityController.text.trim();
    final country = _countryController.text.trim();
    final phone = _phoneController.text.trim();
    final hasMissingRequired =
        name.isEmpty ||
        street.isEmpty ||
        postalCode.isEmpty ||
        city.isEmpty ||
        country.isEmpty ||
        phone.isEmpty;

    if (hasMissingRequired) {
      setState(() => _showRequiredErrors = true);
      return;
    }

    Navigator.of(context).pop(
      Adressmodel(
        id: widget.generatedId,
        name: name,
        street: street,
        postalCode: postalCode,
        city: city,
        country: country,
        phoneNumber: phone,
        isDefault: _isDefault,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.current == null
                  ? 'Ajouter une adresse'
                  : 'Modifier adresse',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            _FormInput(
              controller: _nameController,
              label: 'Nom adresse',
              errorText: _requiredError(_nameController.text),
            ),
            _FormInput(
              controller: _streetController,
              label: 'Rue',
              errorText: _requiredError(_streetController.text),
            ),
            Row(
              children: [
                Expanded(
                  child: _FormInput(
                    controller: _postalController,
                    label: 'Code postal',
                    errorText: _requiredError(_postalController.text),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FormInput(
                    controller: _cityController,
                    label: 'Ville',
                    errorText: _requiredError(_cityController.text),
                  ),
                ),
              ],
            ),
            _FormInput(
              controller: _countryController,
              label: 'Pays',
              errorText: _requiredError(_countryController.text),
            ),
            _FormInput(
              controller: _phoneController,
              label: 'Telephone',
              keyboardType: TextInputType.phone,
              errorText: _requiredError(_phoneController.text),
            ),
            CheckboxListTile(
              value: _isDefault,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: const Text('Definir comme adresse par defaut'),
              onChanged: (value) {
                setState(() => _isDefault = value ?? false);
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _submit,
                child: const Text('Sauvegarder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdressCard extends StatelessWidget {
  final Adressmodel adress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onMakeDefault;

  const _AdressCard({
    required this.adress,
    required this.onEdit,
    required this.onDelete,
    required this.onMakeDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF2F0EE),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            adress.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        if (adress.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDFF3E9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Par defaut',
                              style: TextStyle(
                                color: Color(0xFF2E7D5A),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (adress.street ?? '').trim(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      '${(adress.postalCode ?? '').trim()} ${(adress.city ?? '').trim()}'
                          .trim(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      (adress.country ?? '').trim(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      (adress.phoneNumber ?? '').trim(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: Colors.brown.withOpacity(0.2)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 4,
              runSpacing: 2,
              children: [
                if (onMakeDefault != null)
                  TextButton.icon(
                    onPressed: onMakeDefault,
                    icon: const Icon(
                      Icons.check,
                      color: Color(0xFF2E7D5A),
                      size: 18,
                    ),
                    label: const Text(
                      'Definir par defaut',
                      style: TextStyle(color: Color(0xFF2E7D5A)),
                    ),
                  ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.text,
                    size: 18,
                  ),
                  label: const Text(
                    'Modifier',
                    style: TextStyle(color: AppColors.text),
                  ),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 18,
                  ),
                  label: const Text(
                    'Supprimer',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final String? errorText;

  const _FormInput({
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.text),
          errorText: errorText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
