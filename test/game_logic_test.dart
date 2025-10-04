import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/utils/game_models.dart';
import 'package:tic_tac_toe_app/view_model/game_view_model.dart';

void main() {
  // Group tests related to the GameViewModel
  group('GameViewModel Tests', () {

    // R1 Test: Win detection
    test('Correctly identifies a horizontal win for X', () {
      final viewModel = GameViewModel();
      viewModel.board = [
        PlayerSign.X, PlayerSign.X, PlayerSign.X,
        PlayerSign.O, PlayerSign.none, PlayerSign.O,
        PlayerSign.none, PlayerSign.none, PlayerSign.none,
      ];
      
      // Manually trigger the win check
      viewModel.playerMove(8); // A dummy move to trigger check
      
      expect(viewModel.gameState, GameState.X_Wins);
    });

    test('Correctly identifies a diagonal win for O', () {
      final viewModel = GameViewModel();
      viewModel.board = [
        PlayerSign.O, PlayerSign.X, PlayerSign.X,
        PlayerSign.none, PlayerSign.O, PlayerSign.none,
        PlayerSign.X, PlayerSign.none, PlayerSign.O,
      ];
      
      viewModel.playerMove(3);
      
      expect(viewModel.gameState, GameState.O_Wins);
    });

    // R2 Test: Legal move
    test('Does not allow a move on an already occupied square', () {
      final viewModel = GameViewModel();
      viewModel.playerMove(0); // Player X moves to 0
      
      // Player O tries to move to the same square
      viewModel.playerMove(0); 

      // The board should not have changed from X's move
      expect(viewModel.board[0], PlayerSign.X);
      expect(viewModel.currentPlayer, PlayerSign.O); // It's still O's turn
    });

    // R3 Test: Draw detection
    test('Correctly identifies a draw', () {
      final viewModel = GameViewModel();
      viewModel.board = [
        PlayerSign.X, PlayerSign.O, PlayerSign.X,
        PlayerSign.X, PlayerSign.O, PlayerSign.O,
        PlayerSign.O, PlayerSign.X, PlayerSign.none, // one move left
      ];
      
      viewModel.playerMove(8); // The final move
      
      expect(viewModel.gameState, GameState.Draw);
    });

  });
}
