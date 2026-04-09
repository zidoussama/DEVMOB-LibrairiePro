import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:librairiepro/Config/app_colors.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart' as app_auth;

class PersonalInfoScreen extends StatefulWidget {
	const PersonalInfoScreen({super.key});

	@override
	State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
	late final TextEditingController _firstNameController;
	late final TextEditingController _lastNameController;
	late final TextEditingController _emailController;
	late final TextEditingController _phoneController;
	late final TextEditingController _addressController;

	bool _isEditing = false;
	bool _isLoading = true;
	bool _isSaving = false;

	@override
	void initState() {
		super.initState();
		_firstNameController = TextEditingController();
		_lastNameController = TextEditingController();
		_emailController = TextEditingController();
		_phoneController = TextEditingController();
		_addressController = TextEditingController();
		_loadUserData();
	}

	Future<void> _loadUserData() async {
		final firebaseUser = FirebaseAuth.instance.currentUser;
		if (firebaseUser == null) {
			setState(() => _isLoading = false);
			return;
		}

		try {
			final doc = await FirebaseFirestore.instance
					.collection('users')
					.doc(firebaseUser.uid)
					.get();

			if (!mounted) return;

			if (doc.exists) {
				final data = doc.data() as Map<String, dynamic>;
				_firstNameController.text = (data['firstName'] ?? '').toString();
				_lastNameController.text = (data['lastName'] ?? '').toString();
				_emailController.text = (data['email'] ?? firebaseUser.email ?? '').toString();
				_phoneController.text = (data['phoneNumber'] ?? '').toString();
				_addressController.text = (data['address'] ?? '').toString();
			} else {
				final parts = (firebaseUser.displayName ?? '').trim().split(' ');
				_firstNameController.text = parts.isNotEmpty ? parts.first : '';
				_lastNameController.text =
						parts.length > 1 ? parts.sublist(1).join(' ') : '';
				_emailController.text = firebaseUser.email ?? '';
				_phoneController.text = firebaseUser.phoneNumber ?? '';
				_addressController.text = '';
			}
		} catch (e) {
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text('Erreur chargement profil: $e')),
				);
			}
		} finally {
			if (mounted) {
				setState(() => _isLoading = false);
			}
		}
	}

	Future<void> _saveChanges() async {
		final firebaseUser = FirebaseAuth.instance.currentUser;
		if (firebaseUser == null) return;

		setState(() => _isSaving = true);

		try {
			final firstName = _firstNameController.text.trim();
			final lastName = _lastNameController.text.trim();

			await FirebaseFirestore.instance
					.collection('users')
					.doc(firebaseUser.uid)
					.set({
						'firstName': firstName,
						'lastName': lastName,
						'email': _emailController.text.trim(),
						'phoneNumber': _phoneController.text.trim(),
						'address': _addressController.text.trim(),
					}, SetOptions(merge: true));

			final fullName = '$firstName $lastName'.trim();
			if (fullName.isNotEmpty && firebaseUser.displayName != fullName) {
				await firebaseUser.updateDisplayName(fullName);
				await firebaseUser.reload();
			}

			await context.read<app_auth.AuthProvider>().loadCurrentUser();

			if (!mounted) return;
			setState(() => _isEditing = false);
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('Informations enregistrees')),
			);
		} catch (e) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('Erreur sauvegarde: $e')),
			);
		} finally {
			if (mounted) {
				setState(() => _isSaving = false);
			}
		}
	}

	@override
	void dispose() {
		_firstNameController.dispose();
		_lastNameController.dispose();
		_emailController.dispose();
		_phoneController.dispose();
		_addressController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFFF3F0EC),
			body: SafeArea(
				child: _isLoading
						? const Center(
								child: CircularProgressIndicator(color: AppColors.primary),
							)
						: Column(
								children: [
									_buildHeader(),
									Expanded(
										child: SingleChildScrollView(
											padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													const SizedBox(height: 4),
													Center(
														child: Container(
															width: 96,
															height: 96,
															decoration: const BoxDecoration(
																color: AppColors.primary,
																shape: BoxShape.circle,
															),
															child: const Icon(
																Icons.person_outline,
																color: Colors.white,
																size: 44,
															),
														),
													),
													const SizedBox(height: 20),
													_buildInputField(
														label: 'Prenom',
														icon: Icons.person_outline,
														controller: _firstNameController,
													),
													_buildInputField(
														label: 'Nom',
														icon: Icons.person_outline,
														controller: _lastNameController,
													),
													_buildInputField(
														label: 'Email',
														icon: Icons.mail_outline,
														controller: _emailController,
														keyboardType: TextInputType.emailAddress,
													),
													_buildInputField(
														label: 'Telephone',
														icon: Icons.phone_outlined,
														controller: _phoneController,
														keyboardType: TextInputType.phone,
													),
													_buildInputField(
														label: 'Adresse',
														icon: Icons.location_on_outlined,
														controller: _addressController,
														keyboardType: TextInputType.streetAddress,
													),
													if (_isEditing)
														SizedBox(
															width: double.infinity,
															child: ElevatedButton(
																onPressed: _isSaving ? null : _saveChanges,
																style: ElevatedButton.styleFrom(
																	backgroundColor: AppColors.primary,
																	foregroundColor: Colors.white,
																	padding: const EdgeInsets.symmetric(vertical: 14),
																	shape: RoundedRectangleBorder(
																		borderRadius: BorderRadius.circular(12),
																	),
																),
																child: _isSaving
																		? const SizedBox(
																				height: 18,
																				width: 18,
																				child: CircularProgressIndicator(
																					strokeWidth: 2,
																					color: Colors.white,
																				),
																		)
																		: const Text(
																				'Sauvegarder',
																				style: TextStyle(
																					fontWeight: FontWeight.w600,
																				),
																		),
															),
														),
												],
											),
										),
									),
								],
							),
			),
		);
	}

	Widget _buildHeader() {
		return Container(
			padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
			decoration: BoxDecoration(
				border: Border(
					bottom: BorderSide(
						color: Colors.brown.withOpacity(0.15),
					),
				),
			),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					IconButton(
						onPressed: () => Navigator.of(context).maybePop(),
						icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
					),
					const Expanded(
						child: Text(
							'Informations\npersonnelles',
							style: TextStyle(
								fontSize: 42 / 2,
								fontWeight: FontWeight.w700,
								height: 1.15,
								color: AppColors.text,
							),
						),
					),
					IconButton(
						onPressed: () {
							if (_isSaving) return;
							setState(() => _isEditing = !_isEditing);
						},
						icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
					),
				],
			),
		);
	}

	Widget _buildInputField({
		required String label,
		required IconData icon,
		required TextEditingController controller,
		TextInputType keyboardType = TextInputType.text,
	}) {
		return Padding(
			padding: const EdgeInsets.only(bottom: 14),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							Icon(icon, size: 18, color: AppColors.primary),
							const SizedBox(width: 8),
							Text(
								label,
								style: const TextStyle(
									fontSize: 28 / 2,
									fontWeight: FontWeight.w500,
									color: AppColors.text,
								),
							),
						],
					),
					const SizedBox(height: 8),
					TextFormField(
						controller: controller,
						readOnly: !_isEditing || _isSaving,
						keyboardType: keyboardType,
						style: const TextStyle(fontSize: 16, color: AppColors.text),
						decoration: InputDecoration(
							filled: true,
							fillColor: Colors.white.withOpacity(0.45),
							contentPadding: const EdgeInsets.symmetric(
								horizontal: 14,
								vertical: 14,
							),
							border: OutlineInputBorder(
								borderRadius: BorderRadius.circular(18),
								borderSide: BorderSide(color: Colors.brown.withOpacity(0.12)),
							),
							enabledBorder: OutlineInputBorder(
								borderRadius: BorderRadius.circular(18),
								borderSide: BorderSide(color: Colors.brown.withOpacity(0.12)),
							),
							focusedBorder: OutlineInputBorder(
								borderRadius: BorderRadius.circular(18),
								borderSide: const BorderSide(color: AppColors.primary),
							),
						),
					),
				],
			),
		);
	}
}
