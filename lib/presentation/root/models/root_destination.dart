import 'package:flutter/material.dart';
import 'package:flutter_learning/core/configs/assets/app_vectors.dart';
import 'package:flutter_learning/presentation/appointments/pages/appointment.dart';
import 'package:flutter_learning/presentation/help/pages/help_page.dart';
import 'package:flutter_learning/presentation/profile/pages/profile.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_learning/presentation/settings/pages/settings_page.dart';
import 'package:flutter_learning/presentation/medical_cards/medical_card_page.dart';

class RootDestination {
  final Widget icon;
  final String label;
  final Widget page;
  final bool pinnedToDock;

  RootDestination({
    required this.icon,
    required this.label,
    required this.page,
    this.pinnedToDock = false,
  });
  static final List<RootDestination> rootDestinations = [
    RootDestination(
      icon: Icon(Icons.hourglass_bottom_rounded, size: 30),
      label: 'Sala de espera',
      page: Center(child: Text('Sala de espera')),
      pinnedToDock: true,
    ),
    RootDestination(
      icon: SvgPicture.asset(AppVectors.profile, width: 30),
      label: 'Perfil',
      page: ProfilePage(),
      pinnedToDock: true,
    ),
    RootDestination(
      icon: SvgPicture.asset(AppVectors.addAppointment, width: 30),
      label: 'Añadir',
      page: Center(child: Text('Añadir cita')),
      pinnedToDock: true,
    ),
    RootDestination(
      icon: Icon(Icons.notifications, size: 30),
      label: 'Alertas',
      page: Center(child: Text('Alertas')),
      pinnedToDock: true,
    ),
    RootDestination(
      icon: Icon(Icons.assignment, size: 30),
      label: 'Documentos',
      page: Center(child: Text('Documentos')),
    ),
    RootDestination(
      icon: Icon(Icons.calendar_today, size: 30),
      label: 'Mis citas',
      page: AppointmentPage(),
    ),
    RootDestination(
      icon: Icon(Icons.settings, size: 30),
      label: 'Ajustes',
      page: const SettingsPage(),
    ),
    RootDestination(
      icon: Icon(Icons.question_answer, size: 30),
      label: 'Consulta IA',
      page: Center(child: Text('Consulta con DrBot')),
    ),
    RootDestination(
      icon: Icon(Icons.help_center_rounded, size: 30),
      label: 'Ayuda',
      page: const HelpPage(),
    ),
    RootDestination(
      icon: Icon(Icons.medication_liquid_rounded, size: 30),
      label: 'Medicación prescrita',
      page: Center(child: Text('Medicación prescrita')),
    ),
    RootDestination(
      icon: Icon(Icons.history_rounded, size: 30),
      label: 'Historial clínico',
      page: Center(child: Text('Historial clínico')),
    ),
    RootDestination(
      icon: Icon(Icons.medical_information_rounded, size: 30),
      label: 'Mis tarjetas',
      page: const MedicalCardPage(),
    ),
  ];
}
