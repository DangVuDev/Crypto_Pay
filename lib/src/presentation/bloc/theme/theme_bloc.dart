import 'package:crysta_pay/src/data/datasources/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';


part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final AppPreferences preferences;
  
  ThemeBloc({required this.preferences}) : super(ThemeState(
    themeMode: preferences.getThemeMode(),
  )) {
    on<ChangeTheme>(_onChangeTheme);
  }
  
  Future<void> _onChangeTheme(ChangeTheme event, Emitter<ThemeState> emit) async {
    await preferences.setThemeMode(event.themeMode);
    emit(state.copyWith(themeMode: event.themeMode));
  }
}