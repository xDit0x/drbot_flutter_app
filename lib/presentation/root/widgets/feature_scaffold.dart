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
              HapticFeedback.lightImpact();
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          fontSize: 26,
                          color: Theme.of(context).colorScheme.inverseSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  content: const Text(
                    '¿Seguro que desea cerrar sesión?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  actions: [
                    Column(
                      spacing: 4,
                      children: [
                        FilledButton(
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 13),
                          ),
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            Navigator.pop(dialogContext, true);
                          },
                          child: Row(
                            spacing: 3,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface,
                                weight: 4,
                              ),
                              Text(
                                'Cerrar sesión',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(dialogContext, false);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 42,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainer,
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );

              if (shouldLogout != true || !context.mounted) return;

              await FirebaseAuth.instance.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SignInPage()),
                (route) => false,
              );
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
