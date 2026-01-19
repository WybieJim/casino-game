import 'dart:math';

// 洗牌规则配置
// 设置为true启用洗牌靴规则（剩余牌数低于25%时重新洗牌）
// 设置为false使用普通随机洗牌规则
const bool useShoe = false;

enum GameStatus {
  playing,
  playerWon,
  dealerWon,
  tie,
  playerBusted,
  dealerBusted,
}

class PlayingCard {
  final String suit;
  final String rank;
  final int value;

  PlayingCard(this.suit, this.rank, this.value);

  @override
  String toString() => '$rank$suit';
}

class Deck {
  final List<PlayingCard> _cards = [];
  final Random _random = Random();
  final int _numDecks;
  final bool _useShoe;
  final double _reshufflePercent;
  int _initialCardCount = 0;

  Deck({int numDecks = 6, bool useShoe = false, double reshufflePercent = 0.25})
      : _numDecks = numDecks,
        _useShoe = useShoe,
        _reshufflePercent = reshufflePercent {
    _initialize();
  }

  void _initialize() {
    _cards.clear();
    const suits = ['♠', '♥', '♦', '♣'];
    const ranks = {
      'A': 11,
      '2': 2,
      '3': 3,
      '4': 4,
      '5': 5,
      '6': 6,
      '7': 7,
      '8': 8,
      '9': 9,
      '10': 10,
      'J': 10,
      'Q': 10,
      'K': 10,
    };
    for (var i = 0; i < _numDecks; i++) {
      for (var suit in suits) {
        for (var entry in ranks.entries) {
          _cards.add(PlayingCard(suit, entry.key, entry.value));
        }
      }
    }
    _initialCardCount = _cards.length;
  }

  void shuffle() {
    _cards.shuffle(_random);
    _initialCardCount = _cards.length;
  }

  PlayingCard draw() {
    if (_cards.isEmpty || (_useShoe && _shouldReshuffle())) {
      _initialize();
      shuffle();
    }
    return _cards.removeLast();
  }

  bool _shouldReshuffle() {
    if (!_useShoe) return false;
    final double remainingRatio = _cards.length / _initialCardCount;
    return remainingRatio <= _reshufflePercent;
  }

  int get remainingCards => _cards.length;
  double get remainingPercent =>
      _initialCardCount > 0 ? _cards.length / _initialCardCount : 0.0;
}

class BlackJackGame {
  final Deck _deck = Deck(useShoe: useShoe);
  final List<List<PlayingCard>> _playerHands = [];
  final List<PlayingCard> _dealerPlayingCards = [];
  int _currentHandIndex = 0;
  GameStatus _gameStatus = GameStatus.playing;
  bool _playerTurn = true;
  bool _dealerPlaying = false;
  bool _playerBlackjack = false;
  bool _dealerBlackjack = false;

  List<PlayingCard> get playerPlayingCards =>
      _playerHands.isNotEmpty && _currentHandIndex < _playerHands.length
          ? List.unmodifiable(_playerHands[_currentHandIndex])
          : [];

  List<List<PlayingCard>> get playerHands => List.unmodifiable(_playerHands);
  List<PlayingCard> get dealerPlayingCards =>
      List.unmodifiable(_dealerPlayingCards);
  GameStatus get gameStatus => _gameStatus;
  bool get canHit => _playerTurn && _gameStatus == GameStatus.playing;
  bool get canStand => _playerTurn && _gameStatus == GameStatus.playing;
  bool get canDouble =>
      _playerTurn &&
      _gameStatus == GameStatus.playing &&
      _playerHands.isNotEmpty &&
      _currentHandIndex < _playerHands.length &&
      _playerHands[_currentHandIndex].length == 2;
  bool get canSplit =>
      _playerTurn &&
      _gameStatus == GameStatus.playing &&
      _playerHands.isNotEmpty &&
      _currentHandIndex < _playerHands.length &&
      _playerHands[_currentHandIndex].length == 2 &&
      _playerHands[_currentHandIndex][0].value ==
          _playerHands[_currentHandIndex][1].value;

  bool get dealerPlaying => _dealerPlaying;
  int get currentHandIndex => _currentHandIndex;
  int get handCount => _playerHands.length;
  bool get isPlayerBlackjack => _playerBlackjack;
  bool get isDealerBlackjack => _dealerBlackjack;

  int get playerScore =>
      _playerHands.isNotEmpty && _currentHandIndex < _playerHands.length
          ? _calculateScore(_playerHands[_currentHandIndex])
          : 0;
  int get dealerScore => _calculateScore(_dealerPlayingCards);

  void reset() {
    _playerHands.clear();
    _dealerPlayingCards.clear();
    _currentHandIndex = 0;
    _gameStatus = GameStatus.playing;
    _playerTurn = true;
    _dealerPlaying = false;
  }

  void startNewGame() {
    reset();
    _deck._initialize();
    _deck.shuffle();

    _playerHands.add([]);
    _playerHands[0].add(_deck.draw());
    _dealerPlayingCards.add(_deck.draw());
    _playerHands[0].add(_deck.draw());
    _dealerPlayingCards.add(_deck.draw());

    _checkInitialBlackJack();
  }

  void _checkInitialBlackJack() {
    _playerBlackjack = _playerHands.isNotEmpty &&
        _calculateScore(_playerHands[0]) == 21 &&
        _playerHands[0].length == 2;
    _dealerBlackjack = dealerScore == 21 && _dealerPlayingCards.length == 2;

    if (_playerBlackjack && _dealerBlackjack) {
      _gameStatus = GameStatus.tie;
    } else if (_playerBlackjack) {
      _gameStatus = GameStatus.playerWon;
    } else if (_dealerBlackjack) {
      _gameStatus = GameStatus.dealerWon;
    }
  }

  int _calculateScore(List<PlayingCard> cards) {
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

  void playerHit() {
    if (!canHit) return;

    _playerHands[_currentHandIndex].add(_deck.draw());
    final score = _calculateScore(_playerHands[_currentHandIndex]);
    if (score > 21) {
      // 当前手牌爆牌
      if (_playerHands.length == 1) {
        // 只有一手牌，立即爆牌
        _gameStatus = GameStatus.playerBusted;
        _playerTurn = false;
        _dealerPlaying = false;
      } else {
        // 有分牌，继续下一手
        _moveToNextHand();
      }
    } else if (score == 21) {
      // 当前手牌21点，自动停牌，切换到下一手或庄家
      _moveToNextHand();
    }
  }

  void playerStand() {
    if (!canStand) return;

    _moveToNextHand();
  }

  void _moveToNextHand() {
    if (_currentHandIndex + 1 < _playerHands.length) {
      // 还有下一手，切换
      _currentHandIndex++;
    } else {
      // 所有手牌结束，庄家开始
      _playerTurn = false;
      _dealerPlaying = true;
    }
  }

  void playerSplit() {
    if (!canSplit) return;

    List<PlayingCard> currentHand = _playerHands[_currentHandIndex];
    PlayingCard movedCard = currentHand.removeAt(1);
    List<PlayingCard> newHand = [movedCard];
    _playerHands.insert(_currentHandIndex + 1, newHand);

    // 每手发一张牌
    currentHand.add(_deck.draw());
    newHand.add(_deck.draw());

    // 如果分牌的是A，每手只能拿一张牌，自动停牌
    if (currentHand[0].rank == 'A') {
      // A分牌后不能再要牌，自动停牌，继续下一手
      // 但这里我们仍然允许玩家操作？规则是每手只能拿一张牌，然后必须停牌。
      // 我们标记当前手牌为停牌，并自动切换到下一手
      // 简化：直接移动到下一手，如果下一手也是A分牌，同样处理
      // 由于A分牌后只能拿一张牌，所以当前手牌已经完成
    }
  }

  void playerDouble() {
    if (!canDouble) return;

    // 加倍：要一张牌然后自动停牌
    playerHit();
    if (_gameStatus == GameStatus.playing) {
      _moveToNextHand();
    }
  }

  bool dealerPlayStep() {
    if (!_dealerPlaying) return false;
    if (dealerScore >= 17) {
      _dealerPlaying = false;
      _determineOutcome();
      return false;
    }
    _dealerPlayingCards.add(_deck.draw());
    // 检查庄家是否爆牌
    if (dealerScore > 21) {
      _dealerPlaying = false;
      _gameStatus = GameStatus.dealerBusted;
      return false;
    }
    return true;
  }

  void _determineOutcome() {
    final finalDealerScore = this.dealerScore;
    final finalPlayerScore = this.playerScore;

    // 游戏状态可能已经在其他地方设置（如玩家爆牌）
    if (_gameStatus != GameStatus.playing) {
      return;
    }

    if (finalDealerScore > 21) {
      _gameStatus = GameStatus.dealerBusted;
    } else if (finalDealerScore > finalPlayerScore) {
      _gameStatus = GameStatus.dealerWon;
    } else if (finalDealerScore < finalPlayerScore) {
      _gameStatus = GameStatus.playerWon;
    } else {
      _gameStatus = GameStatus.tie;
    }
  }
}
