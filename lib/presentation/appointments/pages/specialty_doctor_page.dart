import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_learning/domain/entities/appointments/doctor.dart';
import 'package:flutter_learning/domain/usecases/appointments/get_doctors_by_center.dart';
import 'package:flutter_learning/presentation/appointments/models/booking_context.dart';
import 'package:flutter_learning/presentation/appointments/pages/schedule_page.dart';
import 'package:flutter_learning/service_locator.dart';

class SpecialtyDoctorPage extends StatefulWidget {
  final BookingContext booking;
  const SpecialtyDoctorPage({super.key, required this.booking});

  @override
  State<SpecialtyDoctorPage> createState() => _SpecialtyDoctorPageState();
}

class _SpecialtyDoctorPageState extends State<SpecialtyDoctorPage> {
  late Future<Either> _future;
  String? _specialty;

  @override
  void initState() {
    super.initState();
    _future = sl<GetDoctorsByCenterUseCase>().call(
      params: widget.booking.center.code,
    );
  }

  List<Doctor> _filter(List<Doctor> doctors, String specialty) {
    return doctors
        .where((d) => d.specialty == specialty)
        .where(
          (d) => widget.booking.isPublic
              ? d.region == widget.booking.center.region
              : d.insurers.contains(widget.booking.privateCompany),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.booking.center.name,
          style: TextStyle(
            color: scheme.inverseSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<Either>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error inesperado: ${snapshot.error}'));
          }

          return snapshot.data!.fold((l) => Center(child: Text(l.toString())), (
            r,
          ) {
            final all = (r as List).cast<Doctor>();
            if (all.isEmpty) {
              return const Center(
                child: Text('Este hospital no tiene médicos disponibles'),
              );
            }

            final specialties = all.map((d) => d.specialty).toSet().toList()
              ..sort();
            final specialty = _specialty ?? specialties.first;
            final doctors = _filter(all, specialty);

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String>(
                    initialValue: specialty,
                    decoration: const InputDecoration(
                      labelText: 'Especialidad',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final s in specialties)
                        DropdownMenuItem(value: s, child: Text(s)),
                    ],
                    onChanged: (value) => setState(() => _specialty = value),
                  ),
                ),
                const SizedBox(height: 8),
                if (doctors.isEmpty)
                  Text(
                    'No hay médicos de $specialty en tu cobertura.',
                    style: TextStyle(
                      fontSize: 15,
                      color: scheme.onSurfaceVariant,
                    ),
                  )
                else
                  for (final doctor in doctors)
                    Card(
                      color: scheme.surfaceContainer,
                      child: ListTile(
                        leading: Icon(
                          Icons.medical_services_outlined,
                          color: scheme.inverseSurface,
                        ),
                        title: Text(
                          doctor.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${doctor.specialty}\n'
                          '${doctor.insurers.isEmpty ? 'Pública (libre elección)' : doctor.insurers.join(', ')}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SchedulePage(
                                booking: widget.booking,
                                doctor: doctor,
                                specialty: specialty,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              ],
            );
          });
        },
      ),
    );
  }
}
