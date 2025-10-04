// Using enums for game state and player signs makes the code cleaner,
// more readable, and less prone to errors than using simple strings or integers.

enum PlayerSign { X, O, none }

enum Difficulty { Easy, Medium, Hard }

enum GameState { Playing, X_Wins, O_Wins, Draw }
