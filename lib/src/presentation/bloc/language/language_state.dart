part of 'language_bloc.dart';

class LanguageState extends Equatable {
  final Locale locale;
  
  const LanguageState({
    required this.locale,
  });
  
  LanguageState copyWith({
    Locale? locale,
  }) {
    return LanguageState(
      locale: locale ?? this.locale,
    );
  }
  
  @override
  List<Object> get props => [locale];
}