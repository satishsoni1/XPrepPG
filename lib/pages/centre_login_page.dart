import 'package:flutter/material.dart';
import '../theme/brand.dart';
import 'dashboard_page.dart';

class CentreLoginPage extends StatefulWidget {
  const CentreLoginPage({super.key});

  @override
  State<CentreLoginPage> createState() => _CentreLoginPageState();
}

class _CentreLoginPageState extends State<CentreLoginPage> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Centre Login",style: TextStyle(color: Colors.white)),
        backgroundColor: Brand.primary,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _user,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _pass,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading ? null : () {
                  if (_user.text == "centre" && _pass.text == "centre123") {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const DashboardPage()));
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text("Invalid credentials")));
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Brand.primary,
                    minimumSize: const Size(double.infinity, 45)),
                child: const Text("Login",style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
