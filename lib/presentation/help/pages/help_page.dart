import 'package:flutter/material.dart';
import 'package:flutter_learning/core/configs/assets/app_vectors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  static const String _supporMail = 'soporte@drbot.com';

  String _encodeParameters(Map<String, String> params) {
    return params.entries
        .map(
          (entry) =>
              '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}',
        )
        .join('&');
  }

  Future<void> _sendEmail({
    required String subject,
    required String body,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supporMail,
      query: _encodeParameters({'subject': subject, 'body': body}),
    );

    if (!await launchUrl(uri) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puedo abrir la aplicación de correo'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),

      children: [
        const Text(
          'Ayuda',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'DRBOT es una aplicación que permite ayudarte a consultar y organizar información relacionada con tu salud',
        ),
        const SizedBox(height: 20),

        Card(
          child: Column(
            children: [
              ListTile(
                leading: SvgPicture.asset(
                  AppVectors.profile,
                  width: 20,
                  color: Theme.of(context).colorScheme.inverseSurface,
                ),
                title: const Text(
                  'Perfil',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Consulta tu información de contacto y tus datos clínicos',
                ),
              ),
              const ListTile(
                leading: Icon(Icons.local_hospital_outlined),
                title: Text(
                  'Centros de referencia',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Consulta tu centro de salud y hospital asignado',
                ),
              ),
              const ListTile(
                leading: Icon(Icons.calendar_month_outlined),
                title: Text(
                  'Citas',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Consulta y organiza tus citas médicas'),
              ),
              const ListTile(
                leading: Icon(Icons.settings),
                title: Text(
                  'Ajustes',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Configura la aplicación según ajustes de accesibilidad, vibración y seguridad',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Contactar con soporte',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.report_problem_outlined),
                title: Text('Notificar una incidencia'),
                subtitle: Text(
                  'Describe un error o un problema de la aplicación',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    _sendEmail(subject: 'Incidencia en DRBOT', body: ''),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.feedback_outlined),
                title: Text('Enviar comentarios'),
                subtitle: Text(
                  'Comparte una sugerencia o una opinión sobre DRBOT',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    _sendEmail(subject: 'Comentario sobre DRBOT', body: ''),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
