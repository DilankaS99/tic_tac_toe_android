import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../utils/game_models.dart';

class GameViewModel extends ChangeNotifier {
  // --- STATE ---
  // Setup State
  String playerName = "Player 1";
  PlayerSign playerSign = PlayerSign.X;
  PlayerSign get aiSign => (playerSign == PlayerSign.X) ? PlayerSign.O : PlayerSign.X;
  Difficulty difficulty = Difficulty.Easy;

  // Gameplay State
  List<PlayerSign> board = List.filled(9, PlayerSign.none);
  GameState gameState = GameState.Playing;
  PlayerSign _currentPlayer = PlayerSign.X;
  PlayerSign get currentPlayer => _currentPlayer;
  List<PlayerSign>? _previousBoardState; // For the undo feature
  bool _isMediumAiTurnRandom = true;

  // Scoring State
  int wins = 0;
  int losses = 0;
  int draws = 0;

  GameViewModel() {
    loadScores();
  }

  // --- SETUP LOGIC ---
  void setPlayerName(String name) {
    playerName = name.trim().isEmpty ? "Player 1" : name;
    notifyListeners();
  }

  void setPlayerSign(PlayerSign sign) {
    playerSign = sign;
    notifyListeners();
  }

  void setDifficulty(Difficulty level) {
    difficulty = level;
    notifyListeners();
  }

  // --- GAME FLOW LOGIC ---
  void startGame() {
    board = List.filled(9, PlayerSign.none);
    gameState = GameState.Playing;
    _currentPlayer = PlayerSign.X;
    _isMediumAiTurnRandom = true;
    _previousBoardState = null;

    if (aiSign == PlayerSign.X) {
      _makeAiMove();
    }
    notifyListeners();
  }

  void playerMove(int index) {
    if (board[index] != PlayerSign.none || gameState != GameState.Playing) return;

    _previousBoardState = List.from(board); // Save state for undo
    _applyMove(index, playerSign);

    if (gameState == GameState.Playing) {
      Future.delayed(const Duration(milliseconds: 400), _makeAiMove);
    }
  }

  void undoMove() {
    if (_previousBoardState != null) {
      board = List.from(_previousBoardState!);
      gameState = GameState.Playing;
      _currentPlayer = playerSign;
      _previousBoardState = null;
      notifyListeners();
    }
  }

  // --- PRIVATE HELPERS ---
  void _applyMove(int index, PlayerSign sign) {
    board[index] = sign;
    _currentPlayer = (sign == PlayerSign.X) ? PlayerSign.O : PlayerSign.X;
    _checkWinner();
    notifyListeners();
  }

  void _makeAiMove() {
    if (gameState != GameState.Playing) return;

    int? move;
    switch (difficulty) {
      case Difficulty.Easy:
        move = _easyAiMove();
        break;
      case Difficulty.Medium:
        move = _mediumAiMove();
        break;
      case Difficulty.Hard:
        move = _hardAiMove();
        break;
    }

    if (move != null) {
      _applyMove(move, aiSign);
    }
  }

  // --- AI STRATEGIES (Requirement R4) ---
  int? _easyAiMove() {
    final emptySquares = _getEmptySquares();
    return emptySquares.isEmpty ? null : emptySquares[Random().nextInt(emptySquares.length)];
  }

  int? _mediumAiMove() {
    int? move = _isMediumAiTurnRandom ? _easyAiMove() : _hardAiMove();
    _isMediumAiTurnRandom = !_isMediumAiTurnRandom;
    return move;
  }

  int? _hardAiMove() {
    // Implements Pseudocode 1 from the brief
    // 1. Check for a winning move for AI
    int? winningMove = _findWinningMove(aiSign);
    if (winningMove != null) return winningMove;

    // 1. Check to block player's winning move
    int? blockingMove = _findWinningMove(playerSign);
    if (blockingMove != null) return blockingMove;

    // 3. Take the center if free
    if (board[4] == PlayerSign.none) return 4;

    // 4. Take opposite corner
    if (board[0] == playerSign && board[8] == PlayerSign.none) return 8;
    if (board[8] == playerSign && board[0] == PlayerSign.none) return 0;
    if (board[2] == playerSign && board[6] == PlayerSign.none) return 6;
    if (board[6] == playerSign && board[2] == PlayerSign.none) return 2;

    // 5. Take any free corner
    final corners = [0, 2, 6, 8]..shuffle();
    for (var corner in corners) {
      if (board[corner] == PlayerSign.none) return corner;
    }

    // 6. Take any empty square
    return _easyAiMove();
  }
  
  List<int> _getEmptySquares() {
    return [for (int i = 0; i < 9; i++) if (board[i] == PlayerSign.none) i];
  }
  
  int? _findWinningMove(PlayerSign sign) {
    for (int i = 0; i < 9; i++) {
      if (board[i] == PlayerSign.none) {
        board[i] = sign;
        if (_isWinning(sign)) {
          board[i] = PlayerSign.none;
          return i;
        }
        board[i] = PlayerSign.none;
      }
    }
    return null;
  }

  // --- WIN/DRAW LOGIC (Requirements R1, R3) ---
  void _checkWinner() {
    if (_isWinning(PlayerSign.X)) {
      gameState = GameState.X_Wins;
      playerSign == PlayerSign.X ? wins++ : losses++;
    } else if (_isWinning(PlayerSign.O)) {
      gameState = GameState.O_Wins;
      playerSign == PlayerSign.O ? wins++ : losses++;
    } else if (_getEmptySquares().isEmpty) {
      gameState = GameState.Draw;
      draws++;
    }

    if (gameState != GameState.Playing) {
      saveScores();
    }
  }

  bool _isWinning(PlayerSign sign) {
    const lines = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]];
    for (var line in lines) {
      if (board[line[0]] == sign && board[line[1]] == sign && board[line[2]] == sign) return true;
    }
    return false;
  }

  // --- PERSISTENCE (Requirement R6) ---
  Future<void> loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    wins = prefs.getInt('ttt_wins') ?? 0;
    losses = prefs.getInt('ttt_losses') ?? 0;
    draws = prefs.getInt('ttt_draws') ?? 0;
    notifyListeners();
  }

  Future<void> saveScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ttt_wins', wins);
    await prefs.setInt('ttt_losses', losses);
    await prefs.setInt('ttt_draws', draws);
  }
}