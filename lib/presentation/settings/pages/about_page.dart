import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatelessWidget
{
  const AboutPage({super.key});

  Future<String> _getVersion() async
  {
    final info = await PackageInfo.fromPlatform();
    return 'Versión ${info.version}';
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: const Text('Acerca de la app'),
      ),
      body: Center(
        child: FutureBuilder<String>
        (
          future: _getVersion(),
          builder: (context, snapshot)
          {
            final version = snapshot.data ?? 'Cargando versión...';

            return Column
            (
              mainAxisSize: MainAxisSize.min,

              children: 
              [
                Image.asset
                (
                  'assets/images/drbot_logo_transparente.png',
                  width: 120,
                  height: 120,
                ),

                const SizedBox(height: 20),
                Text(version),
                const SizedBox(height: 20),
                const Text
                (
                  'Dr. Bot',
                  style: TextStyle
                  (
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            );
          }
        )
      )
    );
  }
}