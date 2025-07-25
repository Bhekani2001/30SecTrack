import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/account_model.dart';
import '../repositories/account_repository.dart';

class AccountService {
  final AccountRepository repository;

  final String baseUrl = 'http://10.0.2.2:8000/auth'; 

  AccountService(this.repository);

  Future<int> register(Account account) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(account.toMap()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final registeredAccount = Account.fromMap(data);
        await repository.register(registeredAccount);
        return registeredAccount.id ?? 0;
      } else {
        throw Exception('Failed to register on server');
      }
    } catch (e) {
      return await repository.register(account);
    }
  }

  Future<Account?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final account = Account.fromMap(data);
        await repository.register(account);
        return account;
      } else {
        throw Exception('API login failed');
      }
    } catch (e) {
      return await repository.login(email, password);
    }
  }

  Future<Account?> getProfile(int id) async {
    Account? account = await repository.getProfile(id);

    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        account = Account.fromMap(data);
        await repository.updateProfile(account);
      }
    } catch (e) {
    }

    return account;
  }

  Future<int> updateProfile(Account account) async {
    final rows = await repository.updateProfile(account);

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${account.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(account.toMap()),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update on server');
      }
    } catch (e) {
    }

    return rows;
  }

  Future<Account?> forgotPassword(String email) async {
    Account? account = await repository.forgotPassword(email);

    if (account == null) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/forgot-password'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          account = Account.fromMap(data);
          await repository.register(account);
        }
      } catch (e) {
      }
    }

    return account;
  }
}
