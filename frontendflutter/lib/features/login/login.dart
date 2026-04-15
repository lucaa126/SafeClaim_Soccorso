import 'package:flutter/material.dart';
import '../dashboard/dashboard_page.dart'; // dashboard
import 'login_api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool rememberMe = false;
  bool hidePassword = true;
  bool isLoading = false;
  final LoginApiService _loginApi = LoginApiService();

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  Future<void> _checkIfLoggedIn() async {
    if (await _loginApi.isLoggedIn()) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardPage(),
        ),
      );
    }
  }

  // FUNZIONE DI LOGIN TRAMITE API
  Future<void> _loginAdmin() async {
    final username = emailController.text.trim();
    final password = passwordController.text.trim();

    // 1. Controllo campi vuoti
    if (username.isEmpty || password.isEmpty) {
      _mostraErrore("Inserisci username e password");
      return;
    }

    setState(() {
      isLoading = true; // Mostriamo la rotellina di caricamento
    });

    try {
      // 2. Effettua il login con Keycloak
      await _loginApi.login(username, password);

      if (!mounted) return;

      // Naviga alla Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardPage(),
        ),
      );
    } catch (e) {
      // Credenziali sbagliate o errore del server
      final errorMessage = e.toString().contains('Login failed') ? e.toString() : 'Credenziali non valide. Riprova.';
      _mostraErrore(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Fermiamo la rotellina
        });
      }
    }
  }

  void _mostraErrore(String messaggio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(messaggio),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 145, 218),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 380,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 25,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Accedi',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Inserisci le tue credenziali',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // USERNAME
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'testuser',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // PASSWORD
                TextField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // RICORDAMI E PASSWORD DIMENTICATA
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value!;
                        });
                      },
                    ),
                    const Text('Ricordami'),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Password dimenticata?'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // BOTTONE LOGIN
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 17, 76, 204),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading ? null : _loginAdmin,
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Accedi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}