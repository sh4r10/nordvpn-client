import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nordvpn_client/pages/countries.dart';
import 'package:nordvpn_client/pages/home.dart';
import 'package:nordvpn_client/pages/login.dart';
import 'package:nordvpn_client/services/account.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  double maxWidth = 480;
  double maxHeight = 830;
  double minWidth = 480;
  double minHeight = 830;

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('NordVPN Client');
    setWindowMaxSize(Size(maxWidth, maxHeight));
    setWindowMinSize(Size(minWidth, minHeight));
  }

  runApp(const NordVPN());
}

class NordVPN extends StatelessWidget {
  const NordVPN({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Poppins',
        ),
        home: const AuthenticationWrapper(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
        });
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkUserAuthentication(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final bool isAuthenticated = snapshot.data as bool;
          return isAuthenticated ? const HomePage() : const LoginPage();
        } else {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator()],
            ),
          );
        }
      },
    );
  }

  Future<bool> checkUserAuthentication() async {
    return await AccountService.isLoggedIn();
  }
}
