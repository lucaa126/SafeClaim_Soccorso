import 'package:flutter/material.dart';
import '../../app/theme.dart';
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
  
  // Variabili per gestire il colore dinamico
  bool isEmailEmpty = true;
  bool isPasswordEmpty = true;

  final LoginApiService _loginApi = LoginApiService();

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();

    // Listener per l'email: aggiorna il colore quando l'utente scrive
    emailController.addListener(() {
      setState(() {
        isEmailEmpty = emailController.text.isEmpty;
      });
    });

    // Listener per la password: aggiorna il colore quando l'utente scrive
    passwordController.addListener(() {
      setState(() {
        isPasswordEmpty = passwordController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    // È buona norma liberare la memoria dei controller
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkIfLoggedIn() async {
    if (await _loginApi.isLoggedIn()) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    }
  }

  Future<void> _loginAdmin() async {
    final username = emailController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _mostraErrore("Inserisci username e password");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _loginApi.login(username, password);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } catch (e) {
      // Credenziali sbagliate o errore del server
      final errorMessage = e.toString().contains('Login failed')
          ? e.toString()
          : 'Credenziali non valide. Riprova.';
      _mostraErrore(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _mostraErrore(String messaggio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          messaggio,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: SafeClaimColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? SafeClaimColors.darkBackground
        : SafeClaimColors.background;
    final surfaceColor = isDark ? SafeClaimColors.darkCard : Colors.white;
    final panelColor = isDark
        ? SafeClaimColors.darkSurface
        : SafeClaimColors.primaryLightest;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : SafeClaimColors.primaryLight;
    final primaryColor = isDark
        ? SafeClaimColors.primaryLight
        : SafeClaimColors.primary;
    final accentColor = isDark
        ? SafeClaimColors.primaryLight
        : SafeClaimColors.primaryDark;
    final textColor = isDark ? Colors.white : SafeClaimColors.foreground;
    final mutedTextColor = isDark ? Colors.white70 : SafeClaimColors.textMuted;
    final inputFillColor = isDark
        ? SafeClaimColors.darkBackground
        : Colors.white;

    InputDecoration inputDecoration(
      String label,
      String hint,
      IconData icon, {
      Widget? suffixIcon,
    }) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: mutedTextColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: inputFillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: TextStyle(color: mutedTextColor),
        hintStyle: TextStyle(color: mutedTextColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: SafeClaimColors.danger, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: SafeClaimColors.danger, width: 2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.40)
                                : Colors.black.withValues(alpha: 0.10),
                            blurRadius: 28,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.local_hospital_outlined,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Soccorsi - SafeClaim',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: textColor,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Accesso operatori',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: mutedTextColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Accedi',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Inserisci username e password per continuare.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: mutedTextColor,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: panelColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.verified_user_outlined,
                                  color: accentColor,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Connessione sicura tramite Keycloak',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: emailController,
                            enabled: !isLoading,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.username],
                            cursorColor: primaryColor,
                            style: TextStyle(color: textColor),
                            decoration: inputDecoration(
                              'Username',
                              'testuser',
                              Icons.person_outline,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: passwordController,
                            enabled: !isLoading,
                            obscureText: hidePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            cursorColor: primaryColor,
                            style: TextStyle(color: textColor),
                            onSubmitted: (_) {
                              if (!isLoading) {
                                _loginAdmin();
                              }
                            },
                            decoration: inputDecoration(
                              'Password',
                              '••••••••',
                              Icons.lock_outline,
                              suffixIcon: IconButton(
                                tooltip: hidePassword
                                    ? 'Mostra password'
                                    : 'Nascondi password',
                                color: mutedTextColor,
                                icon: Icon(
                                  hidePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          hidePassword = !hidePassword;
                                        });
                                      },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: Checkbox(
                                  value: rememberMe,
                                  fillColor: WidgetStateProperty.resolveWith((
                                    states,
                                  ) {
                                    if (states.contains(WidgetState.selected)) {
                                      return primaryColor;
                                    }
                                    return Colors.transparent;
                                  }),
                                  checkColor: Colors.white,
                                  side: BorderSide(color: borderColor),
                                  onChanged: isLoading
                                      ? null
                                      : (value) {
                                          setState(() {
                                            rememberMe = value ?? false;
                                          });
                                        },
                                ),
                              ),
                              Text(
                                'Ricordami',
                                style: TextStyle(
                                  color: mutedTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: primaryColor,
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    onPressed: isLoading ? null : () {},
                                    child: const Text(
                                      'Password dimenticata?',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: isDark
                                    ? const Color(0xFF2D333B)
                                    : const Color(0xFFE4E7EC),
                                disabledForegroundColor: mutedTextColor,
                                elevation: 0,
                                surfaceTintColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
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
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.login_rounded, size: 20),
                                        SizedBox(width: 8),
                                        Text('Accedi'),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
