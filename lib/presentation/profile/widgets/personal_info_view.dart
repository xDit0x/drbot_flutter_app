import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_learning/common/widgets/snackbar/snack_bar_root.dart';
import 'package:flutter_learning/core/configs/theme/app_colors.dart';

import 'package:flutter_learning/domain/entities/clinical/allergy.dart';
import 'package:flutter_learning/domain/entities/clinical/clinical_info.dart';

import 'package:flutter_learning/domain/usecases/clinical/get_clinical_info.dart';
import 'package:flutter_learning/presentation/profile/widgets/allergy_severity_color.dart';

import 'package:flutter_learning/service_locator.dart';

class PersonalInfoView extends StatefulWidget {
  const PersonalInfoView({super.key});

  @override
  State<PersonalInfoView> createState() => _PersonalInfoViewState();
}

class _PersonalInfoViewState extends State<PersonalInfoView> {
  late final Future<Either> _clinicalFuture = sl<GetClinicalInfoUseCase>()
      .call();

  @override
  void initState() {
    super.initState();
  }

  void _showMessage(String message, SnackbarRootType selection) {
    SnackbarRoot.show(context, message, selection: selection);
  }

  Widget _buildClinicalInfo(AsyncSnapshot<Either> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 1.4,
          ),
        ),
      );
    }

    if (snapshot.hasError) {
      return Text('Error inesperado: ${snapshot.error}');
    }

    final result = snapshot.data;
    if (result == null) return const SizedBox.shrink();

    return result.fold<Widget>((error) => Text(error.toString()), (value) {
      final info = value as ClinicalInfo;

      if (info.bloodGroup == null && info.allergies.isEmpty) {
        return const Text('Sin datos personales registrados.');
      }

      final severeAgents = info.allergies
          .where((allergy) => allergy.severity == AllergySeverity.severe)
          .map((allergy) => allergy.agent)
          .join(', ');

      final subtitle = info.allergies.isEmpty
          ? 'Sin alergias conocidas'
          : severeAgents.isEmpty
          ? 'Con alergias conocidas'
          : 'Con alergias graves conocidas: $severeAgents';

      final orderedAllergies = [...info.allergies]
        ..sort((a, b) => a.severity.rank.compareTo(b.severity.rank));

      return Column(
        children: [
          ListTile(
            leading: Icon(
              info.allergies.isNotEmpty
                  ? Icons.warning_amber_rounded
                  : Icons.bloodtype_rounded,
            ),
            title: Text(
              'Grupo ${info.bloodGroup?.label ?? 'No consta'}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(subtitle),
          ),
          for (final allergy in orderedAllergies)
            Card(
              color: Theme.of(context).colorScheme.surfaceContainer,
              child: ListTile(
                title: Text(
                  allergy.agent,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('${allergy.type.label} · ${allergy.reaction}'),
                trailing: Container(
                  padding: EdgeInsets.fromLTRB(12, 1, 12, 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withAlpha(105),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    allergy.severity.label,
                    style: TextStyle(
                      color: allergy.severity.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 72),
      children: [
        const Text(
          'Información personal clínica',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        FutureBuilder<Either>(
          future: _clinicalFuture,
          builder: (context, snapshot) => _buildClinicalInfo(snapshot),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
