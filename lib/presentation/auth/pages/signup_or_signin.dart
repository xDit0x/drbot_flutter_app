import 'package:flutter/material.dart';
import 'package:flutter_learning/common/helpers/is_dark_mode.dart';
import 'package:flutter_learning/common/widgets/appbar/app_bar.dart';
import 'package:flutter_learning/common/widgets/button/basic_app_button.dart';
import 'package:flutter_learning/core/configs/assets/app_images.dart';
import 'package:flutter_learning/core/configs/assets/app_vectors.dart';
import 'package:flutter_learning/core/configs/theme/app_colors.dart';
import 'package:flutter_learning/presentation/auth/pages/signup.dart';
import 'package:flutter_learning/presentation/auth/pages/signin.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignupOrSigninPage extends StatelessWidget {
  const SignupOrSigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: SvgPicture.asset(AppVectors.topPattern, width: 200),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: SvgPicture.asset(AppVectors.bottomPattern, width: 100),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Image.asset(AppImages.authBG, width: 350),
                Container(
                  color: context.isDarkMode
                      ? Colors.black.withAlpha(65)
                      : Colors.black.withAlpha(25),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(AppImages.logo, width: 150),
                  SizedBox(height: 55),
                  Text(
                    "Disfruta De Tu Bienestar",
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(vertical: 21),
                    child: Text(
                      "DrBot es una aplicación Española que provee gestión hospitalaria, y asistencia continua al usuario.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w500,
                        color: context.isDarkMode
                            ? AppColors.grey
                            : AppColors.darkGrey,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: BasicAppButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => SignUpPage(),
                              ),
                            );
                          },
                          title: "Registrarme",
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => SignInPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.isDarkMode
                                ? Color.fromARGB(159, 20, 20, 20)
                                : Color.fromARGB(209, 231, 231, 231),
                            minimumSize: Size.fromHeight(80),
                          ),
                          child: Text(
                            "Iniciar Sesión",
                            style: TextStyle(
                              color: context.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontFamily: 'Satoshi',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Positioned(top: 0, left: 0, right: 0, child: BasicAppbar()),
        ],
      ),
    );
  }
}
