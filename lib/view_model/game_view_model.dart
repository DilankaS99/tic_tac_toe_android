import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../utils/game_models.dart';

class GameViewModel extends ChangeNotifier {
  // --- STATE ---
  // Setup State
  String playerName = "Player 1";
  PlayerSign playerSign = PlayerSign.X;
  Difficulty difficulty = Difficulty.Easy;
  List<String> pastPlayers = [];

  // Gameplay State
  List<PlayerSign> board = List.filled(9, PlayerSign.none);
  GameState gameState = GameState.Playing;
  PlayerSign _currentPlayer = PlayerSign.X;
  List<PlayerSign>? _previousBoardState; // For the undo feature

  // Scoring State (for the current player)
  int wins = 0;
  int losses = 0;
  int draws = 0;

  // --- GETTERS ---
  PlayerSign get aiSign => (playerSign == PlayerSign.X) ? PlayerSign.O : PlayerSign.X;
  PlayerSign get currentPlayer => _currentPlayer;
  bool get canUndo => _previousBoardState != null;

  // --- CONSTRUCTOR ---
  GameViewModel() {
    // We only load the list of past player names when the app starts.
    // Scores are now loaded AFTER a player is selected.
    loadPlayers();
  }

  // --- SETUP & PLAYER MANAGEMENT ---
  void setPlayerName(String name) {
    playerName = name.trim().isEmpty ? "Player 1" : name;
    // When a player is set, load their specific scores.
    loadPlayerScores(playerName);
  }

  void setPlayerSign(PlayerSign sign) {
    playerSign = sign;
    notifyListeners();
  }

  void setDifficulty(Difficulty level) {
    difficulty = level;
    notifyListeners();
  }

  Future<void> addAndSavePlayer(String name) async {
    final newPlayerName = name.trim();
    if (newPlayerName.isEmpty || pastPlayers.contains(newPlayerName)) {
      return; // Don't add empty or duplicate names
    }
    pastPlayers.add(newPlayerName);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('ttt_pastPlayers', pastPlayers);
    notifyListeners();
  }

  Future<void> loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    pastPlayers = prefs.getStringList('ttt_pastPlayers') ?? [];
    notifyListeners();
  }

  // --- GAME FLOW LOGIC ---
  void startGame() {
    board = List.filled(9, PlayerSign.none);
    gameState = GameState.Playing;
    _currentPlayer = PlayerSign.X;
    _isMediumAiTurnRandom = true;
    _previousBoardState = null; // Reset undo state on new game

    if (aiSign == PlayerSign.X) {
      _makeAiMove();
    }
    notifyListeners();
  }

  Future<void> quickStartGame(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final savedSignName = prefs.getString('${name}_sign') ?? 'X';
    final savedDifficultyName = prefs.getString('${name}_difficulty') ?? 'Medium';

    // Update the ViewModel's state
    playerName = name;
    playerSign = PlayerSign.values.firstWhere((e) => e.name == savedSignName, orElse: () => PlayerSign.X);
    difficulty = Difficulty.values.firstWhere((e) => e.name == savedDifficultyName, orElse: () => Difficulty.Medium);

    // Load the scores for this specific player
    await loadPlayerScores(playerName);

    // Start the game logic
    startGame();
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
      _currentPlayer = playerSign; // It's the player's turn again
      _previousBoardState = null; // Can only undo one move at a time
      notifyListeners();
    }
  }

  void _applyMove(int index, PlayerSign sign) {
    board[index] = sign;
    _currentPlayer = (sign == PlayerSign.X) ? PlayerSign.O : PlayerSign.X;
    _checkWinner();
    notifyListeners();
  }

  // --- AI LOGIC ---
  bool _isMediumAiTurnRandom = true;

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
    int? winningMove = _findWinningMove(aiSign);
    if (winningMove != null) return winningMove;
    int? blockingMove = _findWinningMove(playerSign);
    if (blockingMove != null) return blockingMove;
    if (board[4] == PlayerSign.none) return 4;
    if (board[0] == playerSign && board[8] == PlayerSign.none) return 8;
    if (board[8] == playerSign && board[0] == PlayerSign.none) return 0;
    if (board[2] == playerSign && board[6] == PlayerSign.none) return 6;
    if (board[6] == playerSign && board[2] == PlayerSign.none) return 2;
    final corners = [0, 2, 6, 8]..shuffle();
    for (var corner in corners) {
      if (board[corner] == PlayerSign.none) return corner;
    }
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

  // --- WIN/DRAW LOGIC ---
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

  // --- PERSISTENCE ---
  Future<void> saveScores() async {
    final prefs = await SharedPreferences.getInstance();
    // Save scores against the current player's name
    await prefs.setInt('${playerName}_wins', wins);
    await prefs.setInt('${playerName}_losses', losses);
    await prefs.setInt('${playerName}_draws', draws);
  }
  
  Future<void> loadPlayerScores(String name) async {
    final prefs = await SharedPreferences.getInstance();
    // Load scores using the player-specific key. Default to 0 if none exist.
    wins = prefs.getInt('${name}_wins') ?? 0;
    losses = prefs.getInt('${name}_losses') ?? 0;
    draws = prefs.getInt('${name}_draws') ?? 0;
    notifyListeners();
  }

  Future<void> savePlayerSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${playerName}_sign', playerSign.name);
    await prefs.setString('${playerName}_difficulty', difficulty.name);
  }
}