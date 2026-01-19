import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class LocalStorage {
  static const String _userKey = 'casino_user';

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = user.toJson();
    final userString = json.encode(userJson);
    await prefs.setString(_userKey, userString);
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString == null) return null;
    return _decodeUser(userString);
  }

  static User _decodeUser(String userString) {
    try {
      final userJson = json.decode(userString) as Map<String, dynamic>;
      return User.fromJson(userJson);
    } catch (e) {
      // 如果JSON解析失败，可能是旧格式，返回初始用户
      return User.initial('Guest');
    }
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // 更新余额
  static Future<void> updateBalance(int newBalance) async {
    final user = await getUser();
    if (user != null) {
      user.balance = newBalance;
      await saveUser(user);
    }
  }

  // 更新借款余额
  static Future<void> updateLoanBalance(int newLoanBalance) async {
    final user = await getUser();
    if (user != null) {
      user.loanBalance = newLoanBalance;
      await saveUser(user);
    }
  }

  // 添加借款记录
  static Future<void> addLoanRecord(LoanRecord record) async {
    final user = await getUser();
    if (user != null) {
      user.loanHistory.add(record);
      await saveUser(user);
    }
  }
}
