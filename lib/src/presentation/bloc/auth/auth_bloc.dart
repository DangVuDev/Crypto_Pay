import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  
  AuthBloc({required this.authRepository}) : super(const AuthState()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<Login>(_onLogin);
    on<Register>(_onRegister);
    on<Logout>(_onLogout);
    on<UpdateUser>(_onUpdateUser);
    on<CompleteOnboarding>(_onCompleteOnboarding);
    
    // Check auth status on initialization
    add(CheckAuthStatus());
  }
  
  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isChecking: true));
    
    final isAuthenticated = await authRepository.isAuthenticated();
    final isOnboarded = await authRepository.isOnboarded();
    final user = await authRepository.getCurrentUser();
    
    emit(state.copyWith(
      isAuthenticated: isAuthenticated,
      isOnboarded: isOnboarded,
      user: user,
      isChecking: false,
    ));
  }
  
  Future<void> _onLogin(Login event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    final success = await authRepository.login(event.email, event.password);
    
    if (success) {
      final user = await authRepository.getCurrentUser();
      emit(state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: 'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin đăng nhập.',
      ));
    }
  }
  
  Future<void> _onRegister(Register event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    final success = await authRepository.register(
      event.name,
      event.email,
      event.password,
    );
    
    if (success) {
      final user = await authRepository.getCurrentUser();
      emit(state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: 'Đăng ký thất bại. Vui lòng thử lại.',
      ));
    }
  }
  
  Future<void> _onLogout(Logout event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    
    emit(state.copyWith(
      isAuthenticated: false,
      user: null,
    ));
  }
  
  Future<void> _onUpdateUser(UpdateUser event, Emitter<AuthState> emit) async {
    emit(state.copyWith(user: event.user));
  }
  
  Future<void> _onCompleteOnboarding(CompleteOnboarding event, Emitter<AuthState> emit) async {
    await authRepository.setOnboarded(true);
    emit(state.copyWith(isOnboarded: true));
  }
}