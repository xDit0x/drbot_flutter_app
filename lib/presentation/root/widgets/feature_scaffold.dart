import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learning/common/helpers/is_dark_mode.dart';

import 'package:flutter_learning/core/configs/assets/app_vectors.dart';

import 'package:flutter_learning/presentation/auth/pages/signin.dart';
import 'package:flutter_learning/presentation/choose_mode/bloc/theme_cubit.dart';

import 'package:flutter_learning/presentation/root/models/root_destination.dart';
import 'package:flutter_svg/svg.dart';

class FeatureScaffold extends StatelessWidget {
  final RootDestination destination;
  const FeatureScaffold({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) {
            final isDark = context.isDarkMode;
            return Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.read<ThemeCubit>().updateTheme(
                    isDark ? ThemeMode.light : ThemeMode.dark,
                  );
                },
                icon: isDark
                    ? SvgPicture.asset(AppVectors.moonFilled)
                    : Icon(Icons.light_mode),
              ),
            );
          },
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        forceMaterialTransparency: true,
        toolbarHeight: 56,
        centerTitle: true,
        title: Text(
          destination.label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.inverseSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content: const Text('¿Seguro que desea cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Cerrar sesión'),
                    ),
                  ]
                )
              );
              
              if(shouldLogout != true || !context.mounted) return;

              await FirebaseAuth.instance.signOut();

              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (_) => const SignInPage()), 
                (route) => false);
            },
            child: Icon(
              Icons.logout_rounded,
              size: 24,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.only(right: 5), // ← tu padding derecho
        scrolledUnderElevation: 1,
      ),
      body: destination.page,
    );
  }
}
