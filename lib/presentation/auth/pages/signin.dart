import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_learning/common/widgets/appbar/app_bar.dart';
import 'package:flutter_learning/common/widgets/button/basic_app_button.dart';
import 'package:flutter_learning/common/widgets/snackbar/snack_bar_root.dart';
import 'package:flutter_learning/core/configs/assets/app_images.dart';
import 'package:flutter_learning/core/configs/theme/app_colors.dart';
import 'package:flutter_learning/domain/models/auth/signin_user_request.dart';
import 'package:flutter_learning/domain/usecases/auth/send_password_reset_email.dart';
import 'package:flutter_learning/domain/usecases/auth/sign_in.dart';
import 'package:flutter_learning/presentation/auth/pages/signup.dart';
import 'package:flutter_learning/presentation/root/pages/root.dart';
import 'package:flutter_learning/service_locator.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      bottomNavigationBar: _signUpText(context),
      appBar: BasicAppbar(
        title: Image.asset(AppImages.logo, height: 100, width: 100),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _singinText(),
            SizedBox(height: 50),
            _usernameOrEmailField(context),
            SizedBox(height: 20),
            _passwordField(context),
            SizedBox(height: 20),
            BasicAppButton(
              onPressed: () async {
                if (_email.text.trim().isEmpty || _password.text.isEmpty) {
                  SnackbarRoot.show(
                    context,
                    'Introduce el email y la contraseña',
                    selection: SnackbarRootType.warning,
                  );
                  return;
                }
                var result = await sl<SignInUseCase>().call(
                  params: SigninUserRequest(
                    email: _email.text.toString(),
                    password: _password.text.toString(),
                  ),
                );
                if (!mounted) return;
                result.fold(
                  (l) {
                    //LEFT = no ha ido bien
                    SnackbarRoot.show(
                      context,
                      l.toString(),
                      selection: SnackbarRootType.bad,
                    );
                  },
                  (r) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const RootPage(),
                      ),
                      (route) => false,
                    );
                  },
                );
              },
              title: 'Iniciar sesión',
            ),
            SizedBox(height: 14),
            TextButton(
              onPressed: () async {
                final resetEmail = TextEditingController(
                  text: _email.text.trim(),
                );
                final sent = await showDialog<bool>(
                  animationStyle: AnimationStyle(
                    duration: Duration(milliseconds: 250),
                    reverseCurve: Curves.fastOutSlowIn,
                  ),
                  barrierColor: Colors.black.withAlpha(150),
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(
                      'Recuperar contraseña',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: scheme.inverseSurface,
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 16,
                      children: [
                        Text(
                          'Introduce tu correo y te enviaremos un enlace para restablecer la contraseña.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextField(
                          controller: resetEmail,
                          keyboardType: TextInputType.emailAddress,
                          decoration:
                              InputDecoration(hintText: 'Introduzca email')
                                  .applyDefaults(
                                    Theme.of(context).inputDecorationTheme,
                                  ),
                        ),
                      ],
                    ),
                    actions: [
                      Column(
                        spacing: 4,
                        children: [
                          FilledButton(
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 13),
                            ),
                            onPressed: () async {
                              final email = resetEmail.text.trim();
                              if (email.isEmpty || !email.contains('@')) {
                                HapticFeedback.lightImpact();
                                SnackbarRoot.show(
                                  dialogContext,
                                  'Introduce un email válido',
                                  selection: SnackbarRootType.warning,
                                );
                                return;
                              }
                              HapticFeedback.heavyImpact();
                              final result =
                                  await sl<SendPasswordResetEmailUseCase>()
                                      .call(params: email);
                              if (!dialogContext.mounted) return;
                              result.fold(
                                (l) => SnackbarRoot.show(
                                  dialogContext,
                                  l.toString(),
                                  selection: SnackbarRootType.bad,
                                ),
                                (r) => Navigator.pop(dialogContext, true),
                              );
                            },
                            child: Row(
                              spacing: 3,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.mail,
                                  color: scheme.inverseSurface,
                                  weight: 4,
                                ),
                                Text(
                                  'Enviar enlace',
                                  style: TextStyle(
                                    color: scheme.inverseSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(dialogContext, false);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 42,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: scheme.surfaceContainer,
                              ),
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: scheme.inverseSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );

                if (!mounted) return;
                if (sent == true) {
                  SnackbarRoot.show(
                    context,
                    'Correo enviado, revisa tu bandeja de entrada.',
                    selection: SnackbarRootType.ok,
                  );
                }
              },
              child: Text(
                "¿Olvidaste la contraseña?",
                style: TextStyle(
                  color: scheme.inverseSurface,
                  fontWeight: FontWeight.w500,
                  decorationStyle: TextDecorationStyle.solid,
                  decoration: TextDecoration.underline,
                  decorationThickness: 0.6,
                  decorationColor: scheme.inverseSurface,
                  fontSize: 16,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _singinText() {
    return Text(
      'Iniciar sesión',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      textAlign: TextAlign.center,
    );
  }

  Widget _usernameOrEmailField(BuildContext context) {
    return TextField(
      controller: _email,
      decoration: InputDecoration(hintText: 'Introduce email')
          .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextField(
      controller: _password,
      decoration: InputDecoration(hintText: 'Contraseña')
          .applyDefaults(Theme.of(context).inputDecorationTheme),
      obscureText: true,
    );
  }

  Widget _signUpText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "¿No tienes una cuenta?",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => SignUpPage(),
                ),
              );
            },
            child: Text(
              "Registrarse",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
