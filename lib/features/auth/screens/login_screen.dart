import 'package:flutter/material.dart';
import './register_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../weather/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connexion - Météo Now"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "Nom de L'utilisateur",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Saisir votre Mot de passe ici ",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            TextButton(
                onPressed: () {
                  //passer au page d'inscription
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterScreen()));
                },
                child: const Text(
                    "vous n'avez pas de compte ? creer un compte !")),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
                onPressed: () async {
                  //logique pour lier le bouton a la logique
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  bool success = await authProvider.login(
                      _usernameController.text, _passwordController.text);
                  if (!mounted) return;
                  if (success) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: const Text("Echec de connexion  .")));
                  }
                },
                child: const Text("Se connecter")),
          ],
        ),
      ),
    );
  }
}
