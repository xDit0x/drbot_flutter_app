import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learning/common/helpers/is_dark_mode.dart';
import 'package:flutter_learning/common/widgets/button/basic_app_button.dart';
import 'package:flutter_learning/common/widgets/button/mode_app_button.dart';
import 'package:flutter_learning/core/configs/assets/app_images.dart';
import 'package:flutter_learning/core/configs/assets/app_vectors.dart';
import 'package:flutter_learning/core/configs/theme/app_colors.dart';
import 'package:flutter_learning/presentation/auth/pages/signup_or_signin.dart';
import 'package:flutter_learning/presentation/choose_mode/bloc/theme_cubit.dart';

class ChooseModePage extends StatelessWidget {
  const ChooseModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 40),
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: context.isDarkMode
                    ? AssetImage(AppImages.getStartedBGDarkMode)
                    : AssetImage(AppImages.getStartedBGLightMode),
              ),
            ),
          ),
          Container(color: Colors.black.withAlpha(20)),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      AppImages.logo,
                      width: 150,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Modo preferido',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 21,
                  ),
                ),
                const SizedBox(height: 25),
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, currentMode) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            ModeButton(
                              iconPath: AppVectors.moon,
                              themeMode: ThemeMode.dark,
                              currentThemeMode: currentMode,
                              onTap: () {
                                context.read<ThemeCubit>().updateTheme(
                                  ThemeMode.dark,
                                );
                              },
                            ),
                            SizedBox(height: 15),
                            Text(
                              "Modo oscuro",
                              style: TextStyle(
                                color: context.isDarkMode
                                    ? AppColors.grey
                                    : AppColors.darkGrey,
                                fontFamily: "Satoshi",
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 40),
                        Column(
                          children: [
                            ModeButton(
                              iconPath: AppVectors.sun,
                              themeMode: ThemeMode.light,
                              currentThemeMode: currentMode,
                              onTap: () {
                                context.read<ThemeCubit>().updateTheme(
                                  ThemeMode.light,
                                );
                              },
                            ),
                            SizedBox(height: 15),
                            Text(
                              "Modo claro",
                              style: TextStyle(
                                color: context.isDarkMode
                                    ? AppColors.grey
                                    : AppColors.darkGrey,
                                fontFamily: "Satoshi",
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 50),
                BasicAppButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            const SignupOrSigninPage(),
                      ),
                      (route) => false,
                    );
                  },
                  title: 'Continuar',
                  height: 65,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
