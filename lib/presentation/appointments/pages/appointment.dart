import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_learning/core/configs/theme/app_colors.dart';
import 'package:flutter_learning/domain/usecases/appointments/get_appointments.dart';
import 'package:flutter_learning/service_locator.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  late Future<Either> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = sl<GetAppointmentsUseCase>().call();
  }

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
          return Center();
        });
      },
    );
  }
}
