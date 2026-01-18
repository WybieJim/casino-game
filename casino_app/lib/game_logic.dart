import 'dart:math';

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

  Deck() {
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
    for (var suit in suits) {
      for (var entry in ranks.entries) {
        _cards.add(PlayingCard(suit, entry.key, entry.value));
      }
    }
  }

  void shuffle() {
    _cards.shuffle(_random);
  }

  PlayingCard draw() {
    if (_cards.isEmpty) {
      _initialize();
      shuffle();
    }
    return _cards.removeLast();
  }

  int get remainingCards => _cards.length;
}

class BlackJackGame {
  final Deck _deck = Deck();
  final List<PlayingCard> _playerPlayingCards = [];
  final List<PlayingCard> _dealerPlayingCards = [];
  GameStatus _gameStatus = GameStatus.playing;
  bool _playerTurn = true;

  List<PlayingCard> get playerPlayingCards => List.unmodifiable(_playerPlayingCards);
  List<PlayingCard> get dealerPlayingCards => List.unmodifiable(_dealerPlayingCards);
  GameStatus get gameStatus => _gameStatus;
  bool get canHit => _playerTurn && _gameStatus == GameStatus.playing;
  bool get canStand => _playerTurn && _gameStatus == GameStatus.playing;

  int get playerScore => _calculateScore(_playerPlayingCards);
  int get dealerScore => _calculateScore(_dealerPlayingCards);

  void startNewGame() {
    _playerPlayingCards.clear();
    _dealerPlayingCards.clear();
    _deck._initialize();
    _deck.shuffle();
    _gameStatus = GameStatus.playing;
    _playerTurn = true;

    _playerPlayingCards.add(_deck.draw());
    _dealerPlayingCards.add(_deck.draw());
    _playerPlayingCards.add(_deck.draw());
    _dealerPlayingCards.add(_deck.draw());

    _checkInitialBlackJack();
  }

  void _checkInitialBlackJack() {
    if (playerScore == 21 && dealerScore == 21) {
      _gameStatus = GameStatus.tie;
    } else if (playerScore == 21) {
      _gameStatus = GameStatus.playerWon;
    } else if (dealerScore == 21) {
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

    _playerPlayingCards.add(_deck.draw());
    final score = playerScore;
    if (score > 21) {
      _gameStatus = GameStatus.playerBusted;
      _playerTurn = false;
    } else if (score == 21) {
      playerStand();
    }
  }

  void playerStand() {
    if (!canStand) return;

    _playerTurn = false;
    _dealerPlay();
  }

  void _dealerPlay() {
    while (this.dealerScore < 17) {
      _dealerPlayingCards.add(_deck.draw());
    }

    final finalDealerScore = this.dealerScore;
    final finalPlayerScore = this.playerScore;

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