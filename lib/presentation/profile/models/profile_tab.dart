import 'package:flutter/material.dart';
import 'package:flutter_learning/presentation/profile/widgets/clinic_info_view.dart';
import 'package:flutter_learning/presentation/profile/widgets/contact_info_view.dart';
import 'package:flutter_learning/presentation/profile/widgets/personal_info_view.dart';

class ProfileTab {
  final Widget icon;
  final String label;
  final Widget page;

  ProfileTab({required this.icon, required this.label, required this.page});
  static final List<ProfileTab> profileTabs = [
    ProfileTab(
      icon: Icon(Icons.phone, size: 24),
      label: 'Contacto',
      page: Center(child: ContactInfoView()),
    ),
    ProfileTab(
      icon: Icon(Icons.medical_services, size: 24),
      label: 'Clínica',
      page: Center(child: ClinicInfoView()),
    ),
    ProfileTab(
      icon: Icon(Icons.person, size: 24),
      label: 'Personal',
      page: Center(child: PersonalInfoView()),
    ),
  ];
}
