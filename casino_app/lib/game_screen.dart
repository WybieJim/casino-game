import 'package:flutter/material.dart';
import 'game_logic.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final BlackJackGame game = BlackJackGame();

  @override
  void initState() {
    super.initState();
    game.startNewGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BlackJack 21点'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                game.startNewGame();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDealerSection(),
            const SizedBox(height: 30),
            _buildPlayerSection(),
            const SizedBox(height: 30),
            _buildControls(),
            const SizedBox(height: 20),
            _buildGameStatus(),
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
            Text('点数: ${game.dealerScore}'),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: game.dealerPlayingCards.length,
                itemBuilder: (context, index) {
                  return _buildCardWidget(game.dealerPlayingCards[index]);
                },
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
            const Text(
              '玩家',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('点数: ${game.playerScore}'),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: game.playerPlayingCards.length,
                itemBuilder: (context, index) {
                  return _buildCardWidget(game.playerPlayingCards[index]);
                },
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
              color: card.suit == '♥' || card.suit == '♦' ? Colors.red : Colors.black,
            ),
          ),
          Text(
            card.suit,
            style: TextStyle(
              fontSize: 24,
              color: card.suit == '♥' || card.suit == '♦' ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: game.canHit
              ? () {
                  setState(() {
                    game.playerHit();
                  });
                }
              : null,
          child: const Text('要牌'),
        ),
        ElevatedButton(
          onPressed: game.canStand
              ? () {
                  setState(() {
                    game.playerStand();
                  });
                }
              : null,
          child: const Text('停牌'),
        ),
      ],
    );
  }

  Widget _buildGameStatus() {
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        textAlign: TextAlign.center,
      ),
    );
  }
}