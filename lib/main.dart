import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learning/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:flutter_learning/firebase_options.dart';
import 'package:flutter_learning/presentation/root/pages/root.dart';

import 'package:flutter_learning/service_locator.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter_learning/core/configs/theme/app_theme.dart';
import 'package:path_provider/path_provider.dart';

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
          // home: const SplashPage(),
          home: RootPage(),
        ),
      ),
    );
  }
}
