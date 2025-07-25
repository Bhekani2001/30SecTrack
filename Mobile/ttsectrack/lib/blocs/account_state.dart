import '../models/account_model.dart';

abstract class AccountState {}
class AccountInitial extends AccountState {}
class AccountLoading extends AccountState {}

class AccountRegisterSuccess extends AccountState {
  final Account account;
  AccountRegisterSuccess(this.account);
}
class AccountRegisterFailure extends AccountState {
  final String error;
  AccountRegisterFailure(this.error);
}

class AccountLoginSuccess extends AccountState {
  final Account account;
  AccountLoginSuccess(this.account);
}
class AccountLoginFailure extends AccountState {
  final String error;
  AccountLoginFailure(this.error);
}

class AccountProfileLoaded extends AccountState {
  final Account account;
  AccountProfileLoaded(this.account);
}
class AccountProfileFailure extends AccountState {
  final String error;
  AccountProfileFailure(this.error);
}

class AccountUpdateSuccess extends AccountState {
  final Account account;
  AccountUpdateSuccess(this.account);
}
class AccountUpdateFailure extends AccountState {
  final String error;
  AccountUpdateFailure(this.error);
}

class AccountForgotPasswordSuccess extends AccountState {
  final Account account;
  AccountForgotPasswordSuccess(this.account);
}
class AccountForgotPasswordFailure extends AccountState {
  final String error;
  AccountForgotPasswordFailure(this.error);
}
