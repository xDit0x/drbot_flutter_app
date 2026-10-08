import 'package:flutter/material.dart';
import 'package:flutter_learning/common/widgets/appbar/app_bar.dart';
import 'package:flutter_learning/common/widgets/button/basic_app_button.dart';
import 'package:flutter_learning/common/widgets/snackbar/snack_bar_root.dart';
import 'package:flutter_learning/core/configs/assets/app_images.dart';
import 'package:flutter_learning/core/configs/theme/app_colors.dart';
import 'package:flutter_learning/domain/models/auth/create_user_request.dart';
import 'package:flutter_learning/domain/usecases/auth/sign_up.dart';
import 'package:flutter_learning/presentation/auth/pages/signin.dart';
import 'package:flutter_learning/presentation/root/pages/root.dart';
import 'package:flutter_learning/service_locator.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final TextEditingController _fullname = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _signInText(context),
      appBar: BasicAppbar(
        title: Image.asset(AppImages.logo, height: 100, width: 100),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            _registerText(),
            SizedBox(height: 50),
            _fullNameField(context),
            SizedBox(height: 20),
            _emailField(context),
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
                var result = await sl<SignUpUseCase>().call(
                  params: CreateUserReq(
                    fullName: _fullname.text.toString(),
                    email: _email.text.toString(),
                    password: _password.text.toString(),
                  ),
                );
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
              title: 'Crear cuenta',
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _registerText() {
    return Text(
      'Registrarse',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      textAlign: TextAlign.center,
    );
  }

  Widget _fullNameField(BuildContext context) {
    return TextField(
      controller: _fullname,
      decoration: InputDecoration(hintText: 'Nombre completo')
          .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      decoration: InputDecoration(hintText: 'Introduzca su email')
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

  Widget _signInText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "¿Ya tienes una cuenta?",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => SignInPage(),
                ),
              );
            },
            child: Text(
              "Iniciar sesión",
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
