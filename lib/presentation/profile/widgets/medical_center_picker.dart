import 'package:flutter/material.dart';
import 'package:flutter_learning/domain/entities/clinical/medical_center.dart';

class MedicalCenterPicker extends StatefulWidget
{
  final List<MedicalCenter> centers;
  final bool hospitals;

  const MedicalCenterPicker({
    super.key,
    required this.centers,
    this.hospitals = false,
  });

  @override
  State<MedicalCenterPicker> createState() => _MedicalCenterPickerState();
}

class _MedicalCenterPickerState extends State<MedicalCenterPicker>
{
  String _query = '';

  @override
  Widget build(BuildContext context)
  {
    final results = widget.centers.where((center) 
    {
      final isHospital = center.type.toLowerCase().contains('hospital');
      
      if(isHospital != widget.hospitals) { return false ; }

      final searcheablText = '${center.code} ${center.name} ${center.province} ${center.municipality} ${center.region}';

      return searcheablText.toLowerCase().contains(_query.trim().toLowerCase());
    }).toList();

    return AlertDialog(
      title: Text(widget.hospitals ? 'Elegir hospital' : 'Elegir centro de salud'),
      content: SizedBox(
        width: 520,
        height: 500,
        child: Column(
          children: 
          [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar por nombre, provincia, municipio, comunidad autónoma o código REGCESS',
                border: OutlineInputBorder()
              ),
              onChanged: (value) => setState(() => _query = value),
            ),

            const SizedBox(height: 8),
            
            Align(
              alignment: Alignment.centerLeft,
              child: Text('${results.length} resultados'),
            ),
            
            const SizedBox(height: 4),

            Expanded
            (
              child: results.isEmpty ? const Center(child : Text('No se han encontrado resultados')) : 
              ListView.builder(
                itemCount: results.length,
                
                itemBuilder: (context, index)
                {
                  final center = results[index];

                  return Card
                  (
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(
                        center.type.toLowerCase().contains('hospital')
                            ? Icons.local_hospital_outlined
                            : Icons.medical_services_outlined,
                      ),
                      title: Text(
                        center.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${center.type} · ${center.dependence}'),
                            const SizedBox(height: 4),
                            Text(
                              '${center.municipality}, ${center.province} · ${center.region}',
                            ),
                            if (center.code.isNotEmpty)
                              Text('Código REGCESS: ${center.code}'),
                          ],
                        ),
                      ),
                      onTap: () => Navigator.pop(context, center),
                    ),
                  );
                }
              ),
            ),
          ]
        )
      )
    );
    

  }
}