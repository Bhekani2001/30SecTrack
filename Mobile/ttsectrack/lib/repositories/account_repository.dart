import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import '../models/account_model.dart';

class AccountRepository {
  final Database db;
  final String baseUrl = 'http://10.0.2.2:8000/api/accounts';

  AccountRepository(this.db);

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
        // Insert/update local DB with server response (important to get server ID)
        return await db.insert('accounts', registeredAccount.toMap());
      } else {
        throw Exception('API registration failed');
      }
    } catch (e) {
      // API failed — fallback to local only
      return await db.insert('accounts', account.toMap());
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
        // Save to local DB
        await db.insert('accounts', account.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
        return account;
      }
      throw Exception('Invalid credentials');
    } catch (_) {
      // API failed or invalid credentials — fallback to local
      final result = await db.query(
        'accounts',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
      if (result.isNotEmpty) {
        return Account.fromMap(result.first);
      }
    }
    return null;
  }

  Future<Account?> getProfile(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final account = Account.fromMap(data);
        await db.update('accounts', account.toMap(), where: 'id = ?', whereArgs: [id]);
        return account;
      }
    } catch (_) {
      // ignore error and fallback
    }
    final result = await db.query('accounts', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Account.fromMap(result.first) : null;
  }

  Future<int> updateProfile(Account account) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${account.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(account.toMap()),
      );
      if (response.statusCode == 200) {
        return await db.update('accounts', account.toMap(), where: 'id = ?', whereArgs: [account.id]);
      }
      throw Exception('API update failed');
    } catch (_) {
      // fallback local update only
      return await db.update('accounts', account.toMap(), where: 'id = ?', whereArgs: [account.id]);
    }
  }

  Future<Account?> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final account = Account.fromMap(data);
        // Optionally save locally
        await db.insert('accounts', account.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
        return account;
      }
    } catch (_) {
      // fallback local
    }
    final result = await db.query('accounts', where: 'email = ?', whereArgs: [email]);
    return result.isNotEmpty ? Account.fromMap(result.first) : null;
  }
}
