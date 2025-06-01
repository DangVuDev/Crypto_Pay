part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final bool isAuthenticated;
  final bool isOnboarded;
  final bool isLoading;
  final bool isChecking;
  final UserModel? user;
  final String? error;
  
  const AuthState({
    this.isAuthenticated = false,
    this.isOnboarded = false,
    this.isLoading = false,
    this.isChecking = false,
    this.user,
    this.error,
  });
  
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isOnboarded,
    bool? isLoading,
    bool? isChecking,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      isLoading: isLoading ?? this.isLoading,
      isChecking: isChecking ?? this.isChecking,
      user: user ?? this.user,
      error: error,
    );
  }
  
  @override
  List<Object?> get props => [
    isAuthenticated, isOnboarded, isLoading, isChecking, user, error
  ];
}