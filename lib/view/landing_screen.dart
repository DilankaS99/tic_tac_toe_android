import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe_app/view/game_screen.dart'; // Import GameScreen
import 'package:tic_tac_toe_app/view_model/game_view_model.dart';
import 'package:tic_tac_toe_app/view/setup_screen.dart';
import 'package:tic_tac_toe_app/view/widgets/gradient_background.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});
  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _playNow() {
    final viewModel = context.read<GameViewModel>();
    viewModel.addAndSavePlayer(_nameController.text);
    viewModel.setPlayerName(_nameController.text);
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SetupScreen()),
    );

    // 👇 FIX #2: Clear the controller after navigating away
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            // 👇 FIX (Part A): Wrap the column in a scroll view
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'TIC TAC TOE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 50),
                    TextField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Enter Your Name',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _playNow,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      child: const Text('Play Now'),
                    ),
                    const SizedBox(height: 40),
                    if (viewModel.pastPlayers.isNotEmpty)
                      const Text(
                        'Or select a past player:',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    const SizedBox(height: 10),

                    // 👇 FIX (Part B): REMOVED the Expanded widget
                    ListView.builder(
                      // 👇 FIX (Part C): ADD shrinkWrap so the list doesn't expand
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
                      itemCount: viewModel.pastPlayers.length,
                      itemBuilder: (context, index) {
                        final playerName = viewModel.pastPlayers[index];
                        return Card(
                          color: Colors.white.withOpacity(0.1),
                          child: ListTile(
                            title: Center(
                              child: Text(
                                playerName,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            onTap: () {
                              final viewModel = context.read<GameViewModel>();
                              viewModel.quickStartGame(playerName).then((_) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const GameScreen(),
                                  ),
                                );
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}