import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe_app/utils/game_models.dart';
import 'package:tic_tac_toe_app/view_model/game_view_model.dart';
import 'package:tic_tac_toe_app/view/widgets/gradient_background.dart'; // <-- CORRECTED IMPORT

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Consumer<GameViewModel>(
              builder: (context, viewModel, child) {
                return Column(
                  children: [
                    _Scoreboard(viewModel: viewModel),
                    const Spacer(),
                    _StatusMessage(viewModel: viewModel),
                    const SizedBox(height: 20),
                    _GameBoard(viewModel: viewModel),
                    const Spacer(),
                    _ActionButtons(viewModel: viewModel),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Scoreboard extends StatelessWidget {
  final GameViewModel viewModel;
  const _Scoreboard({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _PlayerInfo(name: viewModel.playerName, sign: viewModel.playerSign, score: viewModel.wins),
          _PlayerInfo(name: 'AI', sign: viewModel.aiSign, score: viewModel.losses),
        ]),
        const SizedBox(height: 10),
        Text('Draws: ${viewModel.draws}', style: const TextStyle(color: Colors.white, fontSize: 18)),
      ],
    );
  }
}

class _PlayerInfo extends StatelessWidget {
  final String name; final PlayerSign sign; final int score;
  const _PlayerInfo({required this.name, required this.sign, required this.score});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(name, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      Text(sign == PlayerSign.X ? 'X' : 'O', style: TextStyle(fontSize: 32, color: sign == PlayerSign.X ? Colors.blueAccent : Colors.redAccent, fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      Text('Wins: $score', style: const TextStyle(color: Colors.white70, fontSize: 16)),
    ]);
  }
}

class _StatusMessage extends StatelessWidget {
  final GameViewModel viewModel;
  const _StatusMessage({required this.viewModel});

  String get _message {
    switch (viewModel.gameState) {
      case GameState.Playing: return viewModel.currentPlayer == viewModel.playerSign ? "Your Turn" : "AI's Turn";
      case GameState.X_Wins: return "Player X Wins!";
      case GameState.O_Wins: return "Player O Wins!";
      case GameState.Draw: return "It's a Draw!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(_message, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center);
  }
}

class _GameBoard extends StatelessWidget {
  final GameViewModel viewModel;
  const _GameBoard({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
        child: GridView.builder(
          itemCount: 9,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: viewModel.currentPlayer == viewModel.playerSign ? () => viewModel.playerMove(index) : null,
              child: Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Center(child: _GridSign(sign: viewModel.board[index])),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GridSign extends StatelessWidget {
  final PlayerSign sign;
  const _GridSign({required this.sign});

  @override
  Widget build(BuildContext context) {
    if (sign == PlayerSign.none) return const SizedBox.shrink();
    return Text(sign == PlayerSign.X ? 'X' : 'O', style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: sign == PlayerSign.X ? Colors.blueAccent : Colors.redAccent));
  }
}

class _ActionButtons extends StatelessWidget {
  final GameViewModel viewModel;
  const _ActionButtons({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      ElevatedButton.icon(onPressed: viewModel.undoMove, icon: const Icon(Icons.undo), label: const Text('Undo')),
      const SizedBox(width: 20),
      ElevatedButton.icon(onPressed: viewModel.startGame, icon: const Icon(Icons.refresh), label: const Text('New Game')),
    ]);
  }
}

