import 'package:crysta_pay/src/data/datasources/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';


part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final AppPreferences preferences;
  
  LanguageBloc({required this.preferences}) : super(LanguageState(
    locale: preferences.getLocale() ?? const Locale('vi', 'VN'),
  )) {
    on<ChangeLanguage>(_onChangeLanguage);
  }
  
  Future<void> _onChangeLanguage(ChangeLanguage event, Emitter<LanguageState> emit) async {
    await preferences.setLocale(event.locale);
    emit(state.copyWith(locale: event.locale));
  }
}