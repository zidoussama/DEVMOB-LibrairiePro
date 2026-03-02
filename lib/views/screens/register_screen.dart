import "package:flutter/material.dart";
import "../widgets/TextFieldUi.dart";

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flèche retour
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF5D4037),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Logo Icône
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6D4C41),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),

                // Titre
                const Text(
                  "Créer un compte",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 8),

                // Sous-titre
                Text(
                  "Rejoignez LibrairiePro",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Carte d'inscription
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Champs Prénom et Nom côte à côte
                      Row(
                        children: [
                          Expanded(
                            child: TextFieldUI(
                              controller: _firstNameController,
                              label: "Prénom",
                              hint: "Jean",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFieldUI(
                              controller: _lastNameController,
                              label: "Nom",
                              hint: "Dupont",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Champ Email
                      TextFieldUI(
                        controller: _emailController,
                        label: "Email",
                        hint: "votre@email.com",
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      // Champ Mot de passe
                      TextFieldUI(
                        controller: _passwordController,
                        label: "Mot de passe",
                        hint: "••••••••",
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Champ Confirmer le mot de passe
                      TextFieldUI(
                        controller: _confirmPasswordController,
                        label: "Confirmer le mot de passe",
                        hint: "••••••••",
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bouton Créer un compte
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implémenter la logique d'inscription
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6D4C41),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Créer un compte",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Lien se connecter
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Déjà un compte ?",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        "Se connecter",
                        style: TextStyle(
                          color: Color(0xFF6D4C41),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
