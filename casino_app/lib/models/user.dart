class User {
  String username;
  int balance; // Y币余额
  int loanBalance; // 借款余额（负数表示欠款）
  List<LoanRecord> loanHistory;
  bool isFirstTime;

  User({
    required this.username,
    required this.balance,
    this.loanBalance = 0,
    this.loanHistory = const [],
    this.isFirstTime = true,
  });

  factory User.initial(String username) {
    return User(
      username: username,
      balance: 6000, // 初始赠送6000Y币
      loanBalance: 0,
      loanHistory: [],
      isFirstTime: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'balance': balance,
      'loanBalance': loanBalance,
      'loanHistory': loanHistory.map((record) => record.toJson()).toList(),
      'isFirstTime': isFirstTime,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      balance: json['balance'],
      loanBalance: json['loanBalance'] ?? 0,
      loanHistory: (json['loanHistory'] as List? ?? [])
          .map((record) => LoanRecord.fromJson(record))
          .toList(),
      isFirstTime: json['isFirstTime'] ?? true,
    );
  }
}

class LoanRecord {
  final int amount; // 正数表示借款，负数表示还款
  final DateTime timestamp;
  final String type; // 'borrow' 或 'repay'

  LoanRecord({
    required this.amount,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }

  factory LoanRecord.fromJson(Map<String, dynamic> json) {
    return LoanRecord(
      amount: json['amount'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
    );
  }

  String get displayAmount => type == 'borrow' ? '+$amount Y币' : '-$amount Y币';
  String get displayDate => '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
}