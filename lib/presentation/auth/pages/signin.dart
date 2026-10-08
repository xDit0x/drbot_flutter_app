import 'package:flutter/material.dart';
import 'package:flutter_learning/common/widgets/appbar/app_bar.dart';
import 'package:flutter_learning/common/widgets/button/basic_app_button.dart';
import 'package:flutter_learning/common/widgets/snackbar/snack_bar_root.dart';
import 'package:flutter_learning/core/configs/assets/app_images.dart';
import 'package:flutter_learning/core/configs/theme/app_colors.dart';
import 'package:flutter_learning/domain/models/auth/signin_user_request.dart';
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
