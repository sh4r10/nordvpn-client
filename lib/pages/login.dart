import 'package:flutter/material.dart';
import 'package:nordvpn_client/services/account.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loginFailed = false;

  final TextEditingController tokenController = TextEditingController();

  @override
  void dispose() {
    tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: Colors.black,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(20),
              child: TextField(
                controller: tokenController,
                decoration: const InputDecoration(
                  hintText: 'Enter your token',
                ),
              ),
            ),
            if (loginFailed)
              const Text(
                "Login failed, please try again",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff3E5FFF),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
              onPressed: () async {
                bool successful =
                    await AccountService.login(tokenController.text);
                if (successful) {
                  Navigator.pushNamed(context, '/home');
                } else {
                  setState(() {
                    loginFailed = true;
                  });
                }
              },
              child: const Text("Login"),
            )
          ],
        ),
      ),
    );
  }
}
