import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ScreenReaderPage extends StatelessWidget
{
  const ScreenReaderPage({super.key});

  @override
  Widget build(BuildContext context)
  {
    final platform = defaultTargetPlatform;

    final String readerName;
    final String instruction;

    if(platform == TargetPlatform.android)
    {
      readerName = 'TalkBack';

      instruction = 'Abre Ajustes del dispositivo, Ve accesibilidad y activa la opción: TalkBack';
    }
    else if(platform == TargetPlatform.iOS)
    {
      readerName = 'VoiceOver';

      instruction = 'Abre Ajustes del dispositivo, Ve accesibilidad y activa la opción: Voice';
    }
    else
    {
      readerName = 'lector de pantalla';

      instruction = 'Activa el lecto de pantalla desde los ajustes de accesibilidad de tu dispositivo';
    }

    return Scaffold(
      appBar: AppBar
      (
        title: const Text('Accesibilidad'),
      ),
      body: 
        
        Padding
        (
          padding: const EdgeInsets.all(24),
        
        child: Column
        (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: 
          [
            const Icon(Icons.speaker),
            const SizedBox(height: 20),
            Text(readerName, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text
            (
              'El lector de pantalla permite leer los elementos de la aplicación en voz alta y los controles.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Text(instruction, style: Theme.of(context).textTheme.bodyLarge)
          ],
        ),
      ),
    );
  }

}