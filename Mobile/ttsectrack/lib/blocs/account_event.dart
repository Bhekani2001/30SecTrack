import '../models/account_model.dart';

abstract class AccountEvent {}
class RegisterEvent extends AccountEvent {
  final Account account;
  RegisterEvent(this.account);
}
class LoginEvent extends AccountEvent {
  final String email;
  final String password;
  LoginEvent(this.email, this.password);
}
class GetProfileEvent extends AccountEvent {
  final int id;
  GetProfileEvent(this.id);
}
class UpdateProfileEvent extends AccountEvent {
  final Account account;
  UpdateProfileEvent(this.account);
}
class ForgotPasswordEvent extends AccountEvent {
  final String email;
  ForgotPasswordEvent(this.email);
}
