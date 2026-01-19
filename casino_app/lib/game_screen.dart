import 'dart:async';
import 'package:flutter/material.dart';
import 'game_logic.dart';
import 'home_screen.dart';
import 'services/local_storage.dart';
import 'models/user.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final BlackJackGame game = BlackJackGame();
  Timer? _dealerTimer;
  bool _dealerAnimating = false;
  User? _user;
  bool _gameStarted = false;
  bool _dealingCards = false;
  int _currentBet = 200;
  bool _hasSettled = false;
  List<PlayingCard> _visibleDealerCards = [];
  bool _hideDealerSecondCard = false;
  int _currentWinnings = 0;

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

  @override
  void dispose() {
    _dealerTimer?.cancel();
    super.dispose();
  }

  void _startDealerAnimation() {
    if (_dealerAnimating) return;
    _dealerAnimating = true;
    _dealerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final continueAnimating = game.dealerPlayStep();
      // 添加庄家新牌到可见列表
      if (game.dealerPlayingCards.length > _visibleDealerCards.length) {
        _visibleDealerCards.add(game.dealerPlayingCards.last);
      }
      setState(() {});
      if (!continueAnimating) {
        timer.cancel();
        _dealerAnimating = false;
      }
    });
  }

  Future<void> _startGame() async {
    if (_user == null) return;

    // 检查余额
    if (_user!.balance < _currentBet) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('余额不足'),
          content: const Text('您的余额不足，无法开始游戏。请前往天使投资页面获取Y币。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              },
              child: const Text('前往天使投资'),
            ),
          ],
        ),
      );
      return;
    }

    // 扣除下注金额
    _user!.balance -= _currentBet;
    await LocalStorage.saveUser(_user!);

    // 开始游戏
    setState(() {
      _gameStarted = true;
      _dealingCards = true;
      _hasSettled = false;
      _visibleDealerCards.clear();
      game.startNewGame();
    });

    // 开始发牌动画（延迟执行）
    _startDealingAnimation();
  }

  void _startDealingAnimation() {
    setState(() {
      _dealingCards = false;
      // 直接显示所有牌（除庄家第二张牌隐藏）
      // 玩家牌已经通过game.playerPlayingCards显示，无需额外处理
      // 庄家牌：显示第一张，第二张隐藏
      if (game.dealerPlayingCards.length > 0 && _visibleDealerCards.isEmpty) {
        _visibleDealerCards.add(game.dealerPlayingCards[0]);
      }
      if (game.dealerPlayingCards.length > 1 &&
          _visibleDealerCards.length == 1) {
        _visibleDealerCards.add(game.dealerPlayingCards[1]);
        _hideDealerSecondCard = true;
      }
    });
  }

  Future<void> _settleGame() async {
    if (_hasSettled || _user == null) return;
    // 显示庄家暗牌（如果还未显示）
    if (_hideDealerSecondCard) {
      _hideDealerSecondCard = false;
    }

    int winnings = 0;
    bool isBlackjackWin = false;

    switch (game.gameStatus) {
      case GameStatus.playerWon:
        if (game.isPlayerBlackjack && !game.isDealerBlackjack) {
          // Blackjack获胜，赔率1:1.5
          winnings = (_currentBet * 1.5).round();
          isBlackjackWin = true;
        } else {
          winnings = _currentBet; // 普通获胜
        }
        break;
      case GameStatus.dealerWon:
        winnings = -_currentBet; // 输掉下注金额
        break;
      case GameStatus.tie:
        winnings = 0; // 平局，返还下注金额
        _user!.balance += _currentBet; // 返还下注金额
        break;
      case GameStatus.playerBusted:
        winnings = -_currentBet; // 爆牌，输掉下注金额
        break;
      case GameStatus.dealerBusted:
        winnings = _currentBet; // 庄家爆牌，赢得下注金额
        break;
      case GameStatus.playing:
        return; // 游戏未结束，不结算
    }

    _currentWinnings = winnings;

    // 更新余额（除了平局已经返还）
    if (game.gameStatus != GameStatus.tie) {
      if (isBlackjackWin) {
        // Blackjack获胜：赢得1.5倍下注，不返还下注金额（因为已经扣除）
        _user!.balance += winnings;
      } else {
        // 普通获胜/输：返还下注金额加上输赢
        _user!.balance += _currentBet + winnings;
      }
    }

    await LocalStorage.saveUser(_user!);
    _hasSettled = true;

    // 更新UI
    setState(() {});
  }

  void _showGameRules() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('21点游戏规则'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '基本规则:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('• 使用6副牌进行游戏'),
              const Text('• 目标: 使手中牌的点数尽可能接近21点，但不能超过'),
              const Text('• 牌面点数: A可计为1或11，J、Q、K计为10，其他牌按牌面点数计算'),
              const SizedBox(height: 12),
              const Text(
                '游戏流程:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('1. 玩家下注（最低200 Y币）'),
              const Text('2. 玩家和庄家各发两张牌，玩家牌明牌，庄家一张明牌一张暗牌'),
              const Text('3. 玩家可选择要牌、停牌、加倍或分牌（条件满足时）'),
              const Text('4. 玩家停牌后，庄家翻开暗牌并按规则要牌（点数<17必须要牌）'),
              const Text('5. 比较双方点数决定胜负'),
              const SizedBox(height: 12),
              const Text(
                '特殊玩法:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('• 加倍: 前两张牌时可选择，下注加倍，只能再拿一张牌'),
              const Text('• 分牌: 前两张牌点数相同时可分牌，分成两手独立进行'),
              const Text('• Blackjack: A + 10点牌，赔率1:1.5'),
              const SizedBox(height: 12),
              const Text(
                '胜负判定:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('• 玩家点数 > 庄家点数: 玩家赢（除爆牌外）'),
              const Text('• 玩家点数 < 庄家点数: 庄家赢'),
              const Text('• 双方点数相同: 平局'),
              const Text('• 超过21点: 爆牌，立即输'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('BlackJack 21点'),
            if (_user != null)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  '余额: ${_user!.balance} Y币',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showGameRules,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                if (_gameStarted) {
                  // 游戏进行中：重置游戏，但不退还下注金额
                  game.reset();
                  _dealerTimer?.cancel();
                  _dealerAnimating = false;
                  // 重新开始游戏（需要重新下注）
                  _gameStarted = false;
                } else {
                  // 游戏未开始：重置下注金额
                  _currentBet = 200;
                }
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF0A5C36), // 深绿色赌桌背景
        ),
        child: Stack(
          children: [
            // 赌桌图案
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      Color(0xFF0A5C36).withOpacity(0.9),
                      Color(0xFF083C24),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildGameContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDealerSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '庄家',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
                '点数: ${_gameStarted ? (_hideDealerSecondCard ? '?' : _calculateVisibleScore(_visibleDealerCards)) : '等待开始'}'),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: _gameStarted && _visibleDealerCards.isNotEmpty
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _visibleDealerCards.length,
                      itemBuilder: (context, index) {
                        if (index == 1 && _hideDealerSecondCard) {
                          return _buildBackCardWidget();
                        } else {
                          return _buildCardWidget(_visibleDealerCards[index]);
                        }
                      },
                    )
                  : Center(
                      child: Text(
                        _gameStarted ? '等待发牌...' : '等待游戏开始',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '玩家',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (game.handCount > 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      '(手牌 ${game.currentHandIndex + 1}/${game.handCount})',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                Spacer(),
                if (_user != null)
                  Text(
                    '余额: ${_user!.balance} Y币',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _user!.balance >= 200 ? Colors.green : Colors.red,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text('点数: ${_gameStarted ? game.playerScore : '等待开始'}'),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: _gameStarted && game.playerPlayingCards.isNotEmpty
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: game.playerPlayingCards.length,
                      itemBuilder: (context, index) {
                        return _buildCardWidget(game.playerPlayingCards[index]);
                      },
                    )
                  : Center(
                      child: Text(
                        _gameStarted ? '等待发牌...' : '等待游戏开始',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardWidget(PlayingCard card) {
    return Container(
      width: 70,
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.rank,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: card.suit == '♥' || card.suit == '♦'
                  ? Colors.red
                  : Colors.black,
            ),
          ),
          Text(
            card.suit,
            style: TextStyle(
              fontSize: 24,
              color: card.suit == '♥' || card.suit == '♦'
                  ? Colors.red
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCardWidget() {
    return Container(
      width: 70,
      height: 100,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.red[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red[800]!, Colors.red[900]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 40,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white, width: 2),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1)
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.spa,
              size: 28,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: (game.canHit && !_dealerAnimating && !_dealingCards)
              ? () {
                  setState(() {
                    game.playerHit();

                    if (game.dealerPlaying) {
                      _startDealerAnimation();
                    }
                  });
                }
              : null,
          child: const Text('要牌'),
        ),
        ElevatedButton(
          onPressed: (game.canStand && !_dealerAnimating && !_dealingCards)
              ? () {
                  setState(() {
                    game.playerStand();
                    // 显示庄家的暗牌
                    _hideDealerSecondCard = false;
                  });
                  _startDealerAnimation();
                }
              : null,
          child: const Text('停牌'),
        ),
        ElevatedButton(
          onPressed: (game.canDouble &&
                  !_dealerAnimating &&
                  !_dealingCards &&
                  _user != null &&
                  _user!.balance >= _currentBet)
              ? () {
                  // 加倍：额外下注当前下注金额
                  setState(() {
                    _user!.balance -= _currentBet;
                    _currentBet *= 2;
                    game.playerDouble();

                    // 显示庄家暗牌（如果玩家停牌后）
                    _hideDealerSecondCard = false;
                    if (game.dealerPlaying) {
                      _startDealerAnimation();
                    }
                  });
                }
              : null,
          child: const Text('加倍'),
        ),
        ElevatedButton(
          onPressed: (game.canSplit &&
                  !_dealerAnimating &&
                  !_dealingCards &&
                  _user != null &&
                  _user!.balance >= _currentBet)
              ? () {
                  // 分牌：额外下注当前下注金额
                  setState(() {
                    _user!.balance -= _currentBet;
                    // 总下注额变为两倍（每手相同下注）
                    _currentBet *= 2;
                    game.playerSplit();
                    // 分牌后UI会自动更新显示当前手牌
                  });
                }
              : null,
          child: const Text('分牌'),
        ),
      ],
    );
  }

  Widget _buildGameStatus() {
    // 如果游戏结束且未结算，进行结算
    if (game.gameStatus != GameStatus.playing && !_hasSettled) {
      Future.microtask(() => _settleGame());
    }

    if (game.gameStatus == GameStatus.playing) {
      return const SizedBox.shrink();
    }
    Color color = Colors.black;
    String message = '';
    switch (game.gameStatus) {
      case GameStatus.playerWon:
        color = Colors.green;
        message = '玩家获胜！';
        break;
      case GameStatus.dealerWon:
        color = Colors.red;
        message = '庄家获胜！';
        break;
      case GameStatus.tie:
        color = Colors.blue;
        message = '平局！';
        break;
      case GameStatus.playerBusted:
        color = Colors.red;
        message = '玩家爆牌！';
        break;
      case GameStatus.dealerBusted:
        color = Colors.green;
        message = '庄家爆牌！玩家获胜！';
        break;
      default:
        message = '';
    }
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Text(
            message,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '本局收益: ${_currentWinnings > 0 ? '+' : ''}$_currentWinnings Y币',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _currentWinnings > 0
                ? Colors.green
                : _currentWinnings < 0
                    ? Colors.red
                    : Colors.blue,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                // 继续游戏：返回开始游戏界面
                setState(() {
                  _gameStarted = false;
                  game.reset();
                  _dealerTimer?.cancel();
                  _dealerAnimating = false;
                });
              },
              child: const Text('继续游戏'),
            ),
            ElevatedButton(
              onPressed: () {
                // 返回主页并传递更新后的用户数据
                Navigator.pop(context, _user);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: const Text('退出游戏'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDealerSection(),
        const SizedBox(height: 30),
        _buildPlayerSection(),
        const SizedBox(height: 30),
        if (_gameStarted)
          Column(
            children: [
              _buildControls(),
              const SizedBox(height: 20),
              _buildGameStatus(),
            ],
          )
        else
          _buildInGameBettingPanel(),
      ],
    );
  }

  int _calculateVisibleScore(List<PlayingCard> cards) {
    int score = 0;
    int aceCount = 0;

    for (var card in cards) {
      score += card.value;
      if (card.rank == 'A') {
        aceCount++;
      }
    }

    while (score > 21 && aceCount > 0) {
      score -= 10;
      aceCount--;
    }
    return score;
  }

  Widget _buildInGameBettingPanel() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '下注',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _user != null && _currentBet > 200
                      ? () {
                          setState(() {
                            _currentBet =
                                (_currentBet - 100).clamp(200, _user!.balance);
                          });
                        }
                      : null,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                Container(
                  width: 120,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    '${_currentBet} Y币',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _user != null &&
                          _user!.balance >= _currentBet + 100
                      ? () {
                          setState(() {
                            _currentBet =
                                (_currentBet + 100).clamp(200, _user!.balance);
                          });
                        }
                      : null,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('最低: 200 Y币'),
                Text('最高: ${_user?.balance ?? 0} Y币'),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  _user != null && _user!.balance >= 200 ? _startGame : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '开始游戏',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 8),
            if (_user != null && _user!.balance < 200)
              Text(
                '余额不足，无法开始游戏',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBettingPanel() {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          padding: EdgeInsets.all(20),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.casino,
                    size: 80,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '21点游戏',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '本局收益: ${_currentWinnings > 0 ? '+' : ''}$_currentWinnings Y币',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _currentWinnings > 0
                          ? Colors.green
                          : _currentWinnings < 0
                              ? Colors.red
                              : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '下注金额',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_currentBet} Y币',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: _currentBet.toDouble(),
                    min: 200,
                    max: _user != null ? _user!.balance.toDouble() : 200,
                    divisions: _user != null
                        ? ((_user!.balance - 200) ~/ 100).clamp(1, 50)
                        : 1,
                    label: '${_currentBet} Y币',
                    onChanged: _user != null
                        ? (value) {
                            setState(() {
                              // 确保下注金额是100的倍数且不低于200
                              int bet = ((value / 100).round() * 100);
                              _currentBet = bet.clamp(200, _user!.balance);
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('最低: 200 Y币'),
                      Text('最高: ${_user?.balance ?? 0} Y币'),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _user != null && _user!.balance >= 200
                        ? _startGame
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '开始游戏',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_user != null && _user!.balance < 200)
                    Text(
                      '余额不足，无法开始游戏',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, _user);
                    },
                    child: const Text('返回主页'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
