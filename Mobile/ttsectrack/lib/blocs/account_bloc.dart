import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/account_model.dart';
import '../services/account_service.dart';
import 'account_event.dart';
import 'account_state.dart';


class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountService service;
  AccountBloc(this.service) : super(AccountInitial()) {
    on<RegisterEvent>((event, emit) async {
      emit(AccountLoading());
      try {
        await service.register(event.account);
        emit(AccountRegisterSuccess(event.account));
      } catch (e) {
        emit(AccountRegisterFailure(e.toString()));
      }
    });
    on<LoginEvent>((event, emit) async {
      emit(AccountLoading());
      try {
        final account = await service.login(event.email, event.password);
        if (account != null) {
          emit(AccountLoginSuccess(account));
        } else {
          emit(AccountLoginFailure('Invalid credentials'));
        }
      } catch (e) {
        emit(AccountLoginFailure(e.toString()));
      }
    });
    on<GetProfileEvent>((event, emit) async {
      emit(AccountLoading());
      try {
        final account = await service.getProfile(event.id);
        if (account != null) {
          emit(AccountProfileLoaded(account));
        } else {
          emit(AccountProfileFailure('Profile not found'));
        }
      } catch (e) {
        emit(AccountProfileFailure(e.toString()));
      }
    });
    on<UpdateProfileEvent>((event, emit) async {
      emit(AccountLoading());
      try {
        await service.updateProfile(event.account);
        emit(AccountUpdateSuccess(event.account));
      } catch (e) {
        emit(AccountUpdateFailure(e.toString()));
      }
    });
    on<ForgotPasswordEvent>((event, emit) async {
      emit(AccountLoading());
      try {
        final account = await service.forgotPassword(event.email);
        if (account != null) {
          emit(AccountForgotPasswordSuccess(account));
        } else {
          emit(AccountForgotPasswordFailure('Email not found'));
        }
      } catch (e) {
        emit(AccountForgotPasswordFailure(e.toString()));
      }
    });
  }
}
