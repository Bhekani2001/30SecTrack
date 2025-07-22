import '../models/account_model.dart';
import '../repositories/account_repository.dart';

class AccountService {
  final AccountRepository repository;
  AccountService(this.repository);

  Future<int> register(Account account) async {
    return await repository.register(account);
  }

  Future<Account?> login(String email, String password) async {
    return await repository.login(email, password);
  }

  Future<Account?> getProfile(int id) async {
    return await repository.getProfile(id);
  }

  Future<int> updateProfile(Account account) async {
    return await repository.updateProfile(account);
  }

  Future<Account?> forgotPassword(String email) async {
    return await repository.forgotPassword(email);
  }
}
