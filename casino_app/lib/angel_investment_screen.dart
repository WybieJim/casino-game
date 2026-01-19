import 'package:flutter/material.dart';
import 'package:casino_app/models/user.dart';
import 'package:casino_app/services/local_storage.dart';

class AngelInvestmentScreen extends StatefulWidget {
  const AngelInvestmentScreen({super.key});

  @override
  State<AngelInvestmentScreen> createState() => _AngelInvestmentScreenState();
}

class _AngelInvestmentScreenState extends State<AngelInvestmentScreen> {
  User? _user;
  final TextEditingController _repayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await LocalStorage.getUser();
    setState(() {
      _user = user;
    });
  }

  Future<void> _borrow() async {
    if (_user == null) return;

    const borrowAmount = 5000;
    final newBalance = _user!.balance + borrowAmount;
    final newLoanBalance = _user!.loanBalance - borrowAmount; // 借款余额为负

    // 更新用户
    _user!.balance = newBalance;
    _user!.loanBalance = newLoanBalance;
    _user!.loanHistory.add(LoanRecord(
      amount: borrowAmount,
      timestamp: DateTime.now(),
      type: 'borrow',
    ));

    await LocalStorage.saveUser(_user!);
    setState(() {});
  }

  Future<void> _repay() async {
    if (_user == null) return;

    final repayAmount = int.tryParse(_repayController.text.trim());
    if (repayAmount == null || repayAmount <= 0) {
      _showErrorDialog('请输入有效的还款金额');
      return;
    }

    if (repayAmount > _user!.balance) {
      _showErrorDialog('余额不足，无法还款');
      return;
    }

    if (repayAmount > _user!.loanBalance.abs()) {
      _showErrorDialog('还款金额不能超过借款总额');
      return;
    }

    final newBalance = _user!.balance - repayAmount;
    final newLoanBalance = _user!.loanBalance + repayAmount; // 还款减少负值

    _user!.balance = newBalance;
    _user!.loanBalance = newLoanBalance;
    _user!.loanHistory.add(LoanRecord(
      amount: -repayAmount, // 负值表示还款
      timestamp: DateTime.now(),
      type: 'repay',
    ));

    await LocalStorage.saveUser(_user!);
    _repayController.clear();
    setState(() {});
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('错误'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('天使投资'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 当前状态卡片
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '当前状态',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('账户余额:'),
                        Text(
                          '${_user!.balance} Y币',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('借款余额:'),
                        Text(
                          '${_user!.loanBalance.abs()} Y币',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: _user!.loanBalance < 0
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    if (_user!.loanBalance < 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '您还有 ${_user!.loanBalance.abs()} Y币 待还',
                          style: const TextStyle(
                            color: Colors.orange,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 借款区域
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '借款',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('点击下方按钮可借款5000 Y币'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _borrow,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          '获取5000 Y币',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 还款区域
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '还款',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _repayController,
                      decoration: const InputDecoration(
                        labelText: '还款金额 (Y币)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.money),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _repay,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          '还款',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 借款历史
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '借款历史',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_user!.loanHistory.isEmpty)
                        const Center(
                          child: Text('暂无借款记录'),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: _user!.loanHistory.length,
                            itemBuilder: (context, index) {
                              final record = _user!.loanHistory[index];
                              return ListTile(
                                leading: Icon(
                                  record.type == 'borrow'
                                      ? Icons.add_circle
                                      : Icons.remove_circle,
                                  color: record.type == 'borrow'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                title: Text(
                                  record.displayAmount,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: record.type == 'borrow'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                subtitle: Text(record.displayDate),
                                trailing:
                                    Text(record.type == 'borrow' ? '借款' : '还款'),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
