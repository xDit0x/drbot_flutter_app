import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_learning/core/configs/theme/app_colors.dart';
import 'package:flutter_learning/domain/entities/clinical/allergy.dart';
import 'package:flutter_learning/domain/usecases/clinical/get_clinical_info.dart';
import 'package:flutter_learning/presentation/profile/widgets/allergy_severity_color.dart';
import 'package:flutter_learning/service_locator.dart';
import 'package:flutter_learning/domain/entities/clinical/clinical_info.dart';

class ClinicInfoView extends StatefulWidget {
  const ClinicInfoView({super.key});

  @override
  State<ClinicInfoView> createState() => _ClinicInfoViewState();
}

class _ClinicInfoViewState extends State<ClinicInfoView> {
  late final Future<Either> _future = sl<GetClinicalInfoUseCase>().call();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 1.4,
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error inesperado: ${snapshot.error}'));
        }
        return snapshot.data!.fold((l) => Center(child: Text(l.toString())), (
          r,
        ) {
          final info = r as ClinicalInfo;
          if (info.bloodGroup == null && info.allergies.isEmpty) {
            return const Center(child: Text('Sin datos clínicos registrados'));
          }
          final severeAgents = info.allergies
              .where((a) => a.severity == AllergySeverity.severe)
              .map((a) => a.agent)
              .join(', ');

          final subtitle = info.allergies.isEmpty
              ? 'Sin alergias conocidas'
              : severeAgents.isEmpty
              ? 'Con alergias conocidas'
              : 'Con alergias graves conocidas: $severeAgents';

          final ordered = [...info.allergies]
            ..sort((a, b) => a.severity.rank.compareTo(b.severity.rank));

          return AnimatedContainer(
            duration: Duration(milliseconds: 2000),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 72),
              children: [
                Text(
                  "Información clínica",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.62,
                  ),
                ),
                SizedBox(height: 20),
                ListTile(
                  leading: info.allergies.isNotEmpty
                      ? Icon(Icons.warning_amber_rounded)
                      : Icon(Icons.bloodtype_rounded),
                  title: Text(
                    'Grupo: ${info.bloodGroup?.label ?? "No consta"}',
                  ),

                  subtitle: Text(subtitle),
                ),
                for (final allergy in ordered)
                  Card(
                    child: ListTile(
                      title: Text(
                        allergy.agent,
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${allergy.type.label} · ${allergy.reaction}',
                      ),
                      trailing: Text(
                        allergy.severity.label,
                        style: TextStyle(
                          color: allergy.severity.color,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
      },
    );
  }
}
