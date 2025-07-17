import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../weather/screens/home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AuthProvider>(context, listen: false).tryAutoLogin(),
      builder: (ctx, authResultSnapshot) {
        if (authResultSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else {
          if (authResultSnapshot.data == true) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        }
      },
    );
  }
}
