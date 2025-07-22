import '../models/account_model.dart';

abstract class AccountState {}
class AccountInitial extends AccountState {}
class AccountLoading extends AccountState {}

// Registration States
class AccountRegisterSuccess extends AccountState {
  final Account account;
  AccountRegisterSuccess(this.account);
}
class AccountRegisterFailure extends AccountState {
  final String error;
  AccountRegisterFailure(this.error);
}

// Login States
class AccountLoginSuccess extends AccountState {
  final Account account;
  AccountLoginSuccess(this.account);
}
class AccountLoginFailure extends AccountState {
  final String error;
  AccountLoginFailure(this.error);
}

// Profile States
class AccountProfileLoaded extends AccountState {
  final Account account;
  AccountProfileLoaded(this.account);
}
class AccountProfileFailure extends AccountState {
  final String error;
  AccountProfileFailure(this.error);
}

// Update Profile States
class AccountUpdateSuccess extends AccountState {
  final Account account;
  AccountUpdateSuccess(this.account);
}
class AccountUpdateFailure extends AccountState {
  final String error;
  AccountUpdateFailure(this.error);
}

// Forgot Password States
class AccountForgotPasswordSuccess extends AccountState {
  final Account account;
  AccountForgotPasswordSuccess(this.account);
}
class AccountForgotPasswordFailure extends AccountState {
  final String error;
  AccountForgotPasswordFailure(this.error);
}
