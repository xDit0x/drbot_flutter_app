import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learning/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:flutter_learning/firebase_options.dart';
import 'package:flutter_learning/presentation/root/pages/authgate.dart';

import 'package:flutter_learning/service_locator.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter_learning/core/configs/theme/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_learning/presentation/settings/widgets/font_scale.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: kIsWeb
          ? HydratedStorageDirectory.web
          : HydratedStorageDirectory((await getTemporaryDirectory()).path),
    );
  } catch (_) {
    HydratedBloc.storage = null;
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDependencies(); //inicializar dependencias de autenticacion
  try {
    await loadFontScale();
  } catch (_) {
    fontScale.value = 1.0;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => ThemeCubit())],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) => MaterialApp(
          title: 'DrBot',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          debugShowCheckedModeBanner: false,

          builder: (context, child) {
            return ValueListenableBuilder<double>(
              valueListenable: fontScale,
              builder: (context, scale, _) {
                final mediaQuery = MediaQuery.of(context);

                return MediaQuery(
                  data: mediaQuery.copyWith(
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
          // home: const SplashPage(),
          home: AuthGate(),
        ),
      ),
    );
  }
}
