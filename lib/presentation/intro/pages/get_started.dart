import 'package:flutter/material.dart';
import 'package:flutter_learning/common/helpers/is_dark_mode.dart';
import 'package:flutter_learning/common/widgets/button/basic_app_button.dart';
import 'package:flutter_learning/core/configs/assets/app_images.dart';
import 'package:flutter_learning/core/configs/theme/app_colors.dart';
import 'package:flutter_learning/presentation/choose_mode/pages/choose_mode.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                  'Gestiona tus consultas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 21,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'Accede a tu calendario de citas médicas, medicamentos recetados y documentos médicos personales',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: context.isDarkMode
                        ? AppColors.grey
                        : AppColors.darkGrey,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50),
                BasicAppButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            const ChooseModePage(),
                      ),
                    );
                  },
                  title: 'Empezar',
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
