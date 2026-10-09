import 'package:flutter/material.dart';
import 'package:flutter_learning/presentation/settings/widgets/font_scale.dart';

class FontSizePage extends StatefulWidget
{
  const FontSizePage({super.key});

  @override
  State<FontSizePage> createState() => _FontSizePageState();
}

class _FontSizePageState extends State<FontSizePage>
{
  String _selectedSize = 'Mediana';

  String _labelForScale(double scale)
  {
    if(scale < 0.9)
    {
      return 'Pequeña';
    }
    if(scale > 1.1)
    {
      return 'Grande';
    }
    return 'Mediana';
  }

  @override
  void initState()
  {
    super.initState();
    _selectedSize = _labelForScale(fontScale.value);
  }

  @override
  Widget build (BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: const Text('Tamaño de letra'),
      ),
      body: Column
      (
        children: 
        [
          RadioGroup<String>
          (
            groupValue: _selectedSize,
            onChanged: (value) 
            {
              if (value == null) { return; }

              setState(() 
              {
                _selectedSize = value;
              });

              final scale = switch (value) 
              {
                'Pequeña' => 0.85,
                'Grande' => 1.2,
                _ => 1.0,
              };

              saveFontScale(scale);
            },
            child: Column(
              children: const [
                RadioListTile<String>
                (
                  title: Text('Pequeña'),
                  value: 'Pequeña',
                ),
                
                RadioListTile<String>
                (
                  title: Text('Mediana'),
                  value: 'Mediana',
                ),
                
                RadioListTile<String>
                (
                  title: Text('Grande'),
                  value: 'Grande',
                ),
              ],
            ),
          ),
        ]
      )
    );
  }
}