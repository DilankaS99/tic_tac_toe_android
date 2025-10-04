import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe_app/utils/game_models.dart';
import 'package:tic_tac_toe_app/view_model/game_view_model.dart';
import 'package:tic_tac_toe_app/view/game_screen.dart';
import 'package:tic_tac_toe_app/view/widgets/gradient_background.dart'; // <-- CORRECTED IMPORT

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

   @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome, ${viewModel.playerName}!',
                      style: const TextStyle(fontSize: 28, color: Colors.white)),
                  const SizedBox(height: 40),
                  const Text('Choose Your Mark',
                      style: TextStyle(fontSize: 22, color: Colors.white70)),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _SignButton(
                        sign: 'X',
                        isSelected: viewModel.playerSign == PlayerSign.X,
                        onTap: () => viewModel.setPlayerSign(PlayerSign.X)),
                    const SizedBox(width: 20),
                    _SignButton(
                        sign: 'O',
                        isSelected: viewModel.playerSign == PlayerSign.O,
                        onTap: () => viewModel.setPlayerSign(PlayerSign.O)),
                  ]),
                  const SizedBox(height: 40),
                  const Text('Choose Difficulty',
                      style: TextStyle(fontSize: 22, color: Colors.white70)),
                  const SizedBox(height: 10),
                  _DifficultyButton(
                      label: 'Easy',
                      isSelected: viewModel.difficulty == Difficulty.Easy,
                      onTap: () => viewModel.setDifficulty(Difficulty.Easy)),
                  const SizedBox(height: 10),
                  _DifficultyButton(
                      label: 'Medium',
                      isSelected: viewModel.difficulty == Difficulty.Medium,
                      onTap: () => viewModel.setDifficulty(Difficulty.Medium)),
                  const SizedBox(height: 10),
                  _DifficultyButton(
                      label: 'Hard',
                      isSelected: viewModel.difficulty == Difficulty.Hard,
                      onTap: () => viewModel.setDifficulty(Difficulty.Hard)),
                      
                  // 👇 THIS IS THE FIX 👇
                  // We replace the Spacer with a SizedBox for consistent spacing.
                  const SizedBox(height: 50),

                  ElevatedButton(
                    onPressed: () {
                      viewModel.savePlayerSettings();
                      viewModel.startGame();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => const GameScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        textStyle: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold,)),
                    child: const Text('Start Game'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignButton extends StatelessWidget {
  final String sign; final bool isSelected; final VoidCallback onTap;
  const _SignButton({required this.sign, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80, height: 80,
        decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.white24, borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text(sign, style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.white))),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label; final bool isSelected; final VoidCallback onTap;
  const _DifficultyButton({required this.label, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.white : Colors.white24, foregroundColor: isSelected ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(label),
      ),
    );
  }
}

