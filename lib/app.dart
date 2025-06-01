import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/config/routes/app_router.dart';
import 'src/config/themes/app_theme.dart';
import 'src/core/di/service_locator.dart';
import 'l10n/app_localizations.dart';
import 'src/presentation/bloc/auth/auth_bloc.dart';
import 'src/presentation/bloc/theme/theme_bloc.dart';
import 'src/presentation/bloc/language/language_bloc.dart';

class CrystaPayApp extends StatelessWidget {
  const CrystaPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ThemeBloc>()),
        BlocProvider(create: (_) => getIt<LanguageBloc>()),
        BlocProvider(create: (_) => getIt<AuthBloc>()),
      ],
      child: Builder(
        builder: (context) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return BlocBuilder<LanguageBloc, LanguageState>(
                builder: (context, languageState) {
                  return MaterialApp.router(
                    title: 'CrystaPay',
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeState.themeMode,
                    routerConfig: appRouter,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: AppLocalizations.supportedLocales,
                    locale: languageState.locale,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}