import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../weather/screens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Inscription "),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Choisissez un nom d'utilisateur",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Mot de passe",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Confirmez le mot de passe",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                    onPressed: () async {
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);

                      bool success = await authProvider.register(
                        _usernameController.text,
                        _passwordController.text,
                      );

                      if (!mounted) return;

                      if (success) {
                        // Afficher un message de succès
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Inscription réussie ! Vous pouvez maintenant vous connecter.")),
                        );
                        // Renvoyer l'utilisateur à l'écran de connexion
                        Navigator.of(context).pop();
                      } else {
                        // Afficher un message d'erreur
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Échec de l'inscription.")),
                        );
                      }
                    },
                    child: Text("inscription")),
              ],
            )));
  }
}
