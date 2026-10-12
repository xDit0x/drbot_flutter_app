import 'package:flutter/material.dart';

import 'package:flutter_learning/domain/entities/clinical/medical_center.dart';

class MedicalCenterPicker extends StatefulWidget {
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

class _MedicalCenterPickerState extends State<MedicalCenterPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final results = widget.centers.where((center) {
      final isHospital = center.type.toLowerCase().contains('hospital');

      if (isHospital != widget.hospitals) {
        return false;
      }

      final searcheablText =
          '${center.code} ${center.name} ${center.province} ${center.municipality} ${center.region}';

      return searcheablText.toLowerCase().contains(_query.trim().toLowerCase());
    }).toList();

    return AlertDialog(
      backgroundColor: scheme.surfaceContainer,
      shadowColor: scheme.surfaceContainerLow,
      title: Text(
        widget.hospitals ? 'Elegir hospital' : 'Elegir centro de salud',
        style: TextStyle(
          color: scheme.inverseSurface,
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: 550,
        height: 570,
        child: Column(
          children: [
            Container(
              width: 180,
              height: 2,
              color: scheme.inversePrimary.withAlpha(150),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar por nombre, provincia, municipio, comunidad autónoma o código REGCESS',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${results.length} resultados',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              ),
            ),

            const SizedBox(height: 4),

            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('No se han encontrado resultados'))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final center = results[index];
                        return Card(
                          shadowColor: scheme.inverseSurface,
                          color: scheme.surfaceContainerHighest,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: Icon(
                              center.type.toLowerCase().contains('hospital')
                                  ? Icons.local_hospital_outlined
                                  : Icons.medical_services_outlined,
                            ),
                            title: Text(
                              center.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.start,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${center.type} · ${center.dependence}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${center.municipality}, ${center.province} · ${center.region}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (center.code.isNotEmpty)
                                    SizedBox(height: 5),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 2,
                                        color: scheme.inverseSurface.withAlpha(
                                          100,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,

                                        children: [
                                          Icon(Icons.code),
                                          Text(
                                            '\tREGCESS\t',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            center.code,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            onTap: () => Navigator.pop(context, center),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
