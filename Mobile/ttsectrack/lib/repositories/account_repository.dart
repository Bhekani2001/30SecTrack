import 'package:sqflite/sqflite.dart';
import '../models/account_model.dart';

class AccountRepository {
  final Database db;
  AccountRepository(this.db);

  Future<int> register(Account account) async {
    return await db.insert('accounts', account.toMap());
  }

  Future<Account?> login(String email, String password) async {
    final result = await db.query(
      'accounts',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return Account.fromMap(result.first);
    }
    return null;
  }

  Future<Account?> getProfile(int id) async {
    final result = await db.query('accounts', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Account.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateProfile(Account account) async {
    return await db.update('accounts', account.toMap(), where: 'id = ?', whereArgs: [account.id]);
  }

  Future<Account?> forgotPassword(String email) async {
    final result = await db.query('accounts', where: 'email = ?', whereArgs: [email]);
    if (result.isNotEmpty) {
      return Account.fromMap(result.first);
    }
    return null;
  }
}
