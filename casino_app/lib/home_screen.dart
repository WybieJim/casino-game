import 'package:flutter/material.dart';
import 'package:casino_app/models/user.dart';
import 'package:casino_app/services/local_storage.dart';
import 'game_screen.dart';
import 'angel_investment_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await LocalStorage.getUser();
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _saveUser(String username) async {
    final newUser = User.initial(username);
    await LocalStorage.saveUser(newUser);
    setState(() {
      _user = newUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 如果用户不存在，显示用户名输入界面
    if (_user == null) {
      return _buildUsernameInput();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('娱乐赌场'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AngelInvestmentScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 用户信息卡片
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '用户名: ${_user!.username}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '余额: ${_user!.balance} Y币',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color:
                            _user!.balance >= 200 ? Colors.green : Colors.red,
                      ),
                    ),
                    if (_user!.loanBalance < 0)
                      Text(
                        '借款余额: ${_user!.loanBalance.abs()} Y币',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.orange,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // 游戏模块
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildGameCard(
                    title: '21点',
                    icon: Icons.casino,
                    onTap: () async {
                      if (_user!.balance < 200) {
                        _showInsufficientBalanceDialog(context);
                        return;
                      }
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GameScreen(),
                        ),
                      );
                      if (result != null && result is User) {
                        // 更新用户数据
                        await LocalStorage.saveUser(result);
                        setState(() {
                          _user = result;
                        });
                      } else {
                        // 刷新用户数据
                        _loadUser();
                      }
                    },
                    enabled: _user!.balance >= 200,
                  ),
                  _buildGameCard(
                    title: '敬请期待',
                    icon: Icons.hourglass_empty,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('功能开发中，敬请期待！'),
                        ),
                      );
                    },
                    enabled: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: enabled ? null : Colors.grey.shade200,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: enabled ? Theme.of(context).primaryColor : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: enabled ? Colors.black : Colors.grey,
                ),
              ),
              if (!enabled && title == '21点')
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    '余额不足',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInsufficientBalanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('余额不足'),
        content: const Text('您的余额低于200 Y币，无法进入21点游戏。\n请前往天使投资页面获取Y币。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AngelInvestmentScreen(),
                ),
              );
            },
            child: const Text('前往天使投资'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameInput() {
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('欢迎来到娱乐赌场'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.casino,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 30),
            const Text(
              '请输入您的用户名',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '首次进入将赠送6000 Y币',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '用户名',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final username = controller.text.trim();
                if (username.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('请输入用户名'),
                    ),
                  );
                  return;
                }
                _saveUser(username);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                child: Text(
                  '开始游戏',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
