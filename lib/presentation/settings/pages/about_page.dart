import 'package:flutter/material.dart';
import 'package:flutter_learning/core/configs/assets/app_images.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<String> _getVersion() async {
    final info = await PackageInfo.fromPlatform();
    return 'Versión ${info.version}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de la app')),
      body: Center(
        child: FutureBuilder<String>(
          future: _getVersion(),
          builder: (context, snapshot) {
            final version = snapshot.data ?? 'Cargando versión...';

            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppImages.transparentLogo, width: 100, height: 100),
                const SizedBox(height: 30),
                Text(
                  version,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Image.asset(AppImages.drbotWord, width: 240, height: 80),
              ],
            );
          },
        ),
      ),
    );
  }
}
