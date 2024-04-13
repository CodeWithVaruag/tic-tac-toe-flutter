import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        primaryColor: Colors.blue,
        hintColor: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: TicTacToeScreen(),
    );
  }
}

class TicTacToeScreen extends StatefulWidget {
  @override
  _TicTacToeScreenState createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  TextEditingController player1Controller = TextEditingController();
  TextEditingController player2Controller = TextEditingController();

  String player1Name = '';
  String player2Name = '';
  bool showPlayer1Form = false;
  bool showPlayer2Form = false;
  bool showBoard = false;

  List<List<Player>> board =
      List.generate(3, (_) => List.filled(3, Player.none));
  Player currentPlayer = Player.X;
  Player winner = Player.none;

  bool isAI = false;
  bool aiFirst = true;
  bool userFirst = true;
  int aiLevel = 1;

  @override
  void initState() {
    super.initState();
    _showOpponentSelection();
  }

  void _showOpponentSelection() {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Choose Opponent"),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isAI = true;
                        Navigator.of(context).pop();
                        _showAILevelSelection();
                      });
                    },
                    child: Text('AI'),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isAI = false;
                        Navigator.of(context).pop();
                        _showPlayerForm();
                      });
                    },
                    child: Text('Local Player'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showAILevelSelection() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose AI Level"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      aiLevel = 1;
                      Navigator.of(context).pop();
                      _showTurnSelection();
                    });
                  },
                  child: Text('Easy'),
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      aiLevel = 2;
                      Navigator.of(context).pop();
                      _showTurnSelection();
                    });
                  },
                  child: Text('Medium'),
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      aiLevel = 3;
                      Navigator.of(context).pop();
                      _showTurnSelection();
                    });
                  },
                  child: Text('Hard'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTurnSelection() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Turn"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      userFirst = true;
                      aiFirst = false;
                      Navigator.of(context).pop();
                      _startGame();
                    });
                  },
                  child: Text('User First'),
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      userFirst = false;
                      aiFirst = true;
                      Navigator.of(context).pop();
                      _startGame();
                    });
                  },
                  child: Text('AI First'),
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      aiFirst = Random().nextBool();
                      userFirst = !aiFirst;
                      Navigator.of(context).pop();
                      _startGame();
                    });
                  },
                  child: Text('Random'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPlayerForm() {
    setState(() {
      showPlayer1Form = true;
    });
  }

  void _startGame() {
    if (isAI) {
      setState(() {
        showBoard = true;
      });
    }
    if (isAI && aiFirst) {
      _makeAIMove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (!showBoard)
                Column(
                  children: [
                    if (showPlayer1Form)
                      _buildPlayerForm(
                          'Enter Player 1 Name:', player1Controller, () {
                        setState(() {
                          player1Name = player1Controller.text;
                          showPlayer1Form = false;
                          showPlayer2Form = true;
                        });
                      }),
                    if (showPlayer2Form)
                      _buildPlayerForm(
                          'Enter Player 2 Name:', player2Controller, () {
                        setState(() {
                          player2Name = player2Controller.text;
                          showPlayer2Form = false;
                          showBoard = true;
                        });
                      }),
                  ],
                ),
              if (showBoard)
                Column(
                  children: [
                    Text(
                      _getPlayerTurn(),
                      style: TextStyle(fontSize: 20.0),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      padding: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Column(
                        children: List.generate(3, (row) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (col) {
                              return GestureDetector(
                                onTap: () {
                                  _makeMove(row, col);
                                },
                                child: Container(
                                  width: 80.0,
                                  height: 80.0,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${getPlayerSymbol(board[row][col])}',
                                      style: TextStyle(fontSize: 40.0),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    if (winner != Player.none ||
                        !board.any((row) => row.contains(Player.none)))
                      Card(
                        color: Colors.blueGrey[100],
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text(
                                '${getGameResult()}',
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 20.0),
                              ElevatedButton(
                                onPressed: () {
                                  _resetGame();
                                },
                                child: Text('Reset Game'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPlayerTurn() {
    if (!isAI) {
      return currentPlayer == Player.X
          ? '$player1Name\'s turn'
          : '$player2Name\'s turn';
    } else {
      return currentPlayer == Player.X ? 'Your turn' : 'AI\'s turn';
    }
  }

  Widget _buildPlayerForm(
      String label, TextEditingController controller, Function() onSubmit) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
            ),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: onSubmit,
            child: Text('Next'),
          ),
        ],
      ),
    );
  }

  void _makeMove(int row, int col) {
    if (board[row][col] == Player.none && winner == Player.none) {
      setState(() {
        board[row][col] = currentPlayer;
        currentPlayer = currentPlayer == Player.X ? Player.O : Player.X;
        _checkWinner();
        if (isAI && currentPlayer == Player.O && winner == Player.none) {
          Timer(Duration(seconds: 1), () {
            _makeAIMove();
          });
        }
      });
    }
  }

  void _makeAIMove() {
    // Simple AI logic: find the first empty cell and fill it
    if (aiLevel == 1) {
      _makeRandomMove(); // Call helper method for random move
    } else if (aiLevel == 2) {
      _makeMediumAIMove(); // Call medium level AI logic
    } else {
      _makeHardAIMove();
    }
  }

  void _makeHardAIMove() {
    // Hard level AI logic using minimax algorithm with alpha-beta pruning
    Point<int>? bestMove;
    int bestScore = -1000;
    int alpha = -1000;
    int beta = 1000;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == Player.none) {
          board[i][j] = Player.O;
          int score = _minimax(false, 0, alpha, beta);
          board[i][j] = Player.none;

          if (score > bestScore) {
            bestScore = score;
            bestMove = Point(i, j);
          }
          alpha = max(alpha, bestScore);
          if (alpha >= beta) {
            break; // Prune remaining branches
          }
        }
      }
    }

    _makeMove(bestMove!.x, bestMove.y);
  }

  int _minimax(bool isMaximizing, int depth, int alpha, int beta) {
    Player currentPlayer = isMaximizing ? Player.O : Player.X;

    int gameResult = _evaluateGameResult();
    const int MAX_DEPTH = 9;
    if (gameResult != 0 || depth >= MAX_DEPTH) {
      return gameResult;
    }

    if (isMaximizing) {
      int bestScore = -1000;

      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (board[i][j] == Player.none) {
            board[i][j] = currentPlayer;
            int score = _minimax(false, depth + 1, alpha, beta);
            board[i][j] = Player.none;
            bestScore = max(bestScore, score);
            alpha = max(alpha, bestScore);
            if (alpha >= beta) {
              break; // Prune remaining branches
            }
          }
        }
      }

      return bestScore;
    } else {
      int bestScore = 1000;

      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (board[i][j] == Player.none) {
            board[i][j] = currentPlayer;
            int score = _minimax(true, depth + 1, alpha, beta);
            board[i][j] = Player.none;
            bestScore = min(bestScore, score);
            beta = min(beta, bestScore);
            if (beta <= alpha) {
              break; // Prune remaining branches
            }
          }
        }
      }

      return bestScore;
    }
  }

  int _evaluateGameResult() {
    for (int i = 0; i < 3; i++) {
      if (board[i][0] != Player.none &&
          board[i][0] == board[i][1] &&
          board[i][0] == board[i][2]) {
        return (board[i][0] == Player.O) ? 10 : -10;
      }
      if (board[0][i] != Player.none &&
          board[0][i] == board[1][i] &&
          board[0][i] == board[2][i]) {
        return (board[0][i] == Player.O) ? 10 : -10;
      }
    }
    if (board[0][0] != Player.none &&
        board[0][0] == board[1][1] &&
        board[0][0] == board[2][2]) {
      return (board[0][0] == Player.O) ? 10 : -10;
    }
    if (board[0][2] != Player.none &&
        board[0][2] == board[1][1] &&
        board[0][2] == board[2][0]) {
      return (board[0][2] == Player.O) ? 10 : -10;
    }
    return 0;
  }

  void _makeMediumAIMove() {
    // Check for winning moves
    Point<int>? winningMove = _getWinningMove(Player.O);
    if (winningMove != null) {
      _makeMove(winningMove.x, winningMove.y);
      return;
    }

    // Check for blocking opponent's winning moves
    Point<int>? blockingMove = _getWinningMove(Player.X);
    if (blockingMove != null) {
      _makeMove(blockingMove.x, blockingMove.y);
      return;
    }

    // If no winning or blocking moves, make a random move
    _makeRandomMove();
  }

  void _makeRandomMove() {
    // Get a list of all empty cells
    List<Point<int>> emptyCells = _getEmptyCells();

    // Check if there are any empty cells
    if (emptyCells.isNotEmpty) {
      // Randomly select an empty cell
      Random random = Random();
      Point<int> randomCell = emptyCells[random.nextInt(emptyCells.length)];

      // Make a move to the randomly selected cell
      _makeMove(randomCell.x, randomCell.y);
    }
  }

// Function to get all empty cells on the board
  List<Point<int>> _getEmptyCells() {
    List<Point<int>> emptyCells = [];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == Player.none) {
          emptyCells.add(Point<int>(i, j));
        }
      }
    }
    return emptyCells;
  }

// Function to get a winning move for a specific player
  Point<int>? _getWinningMove(Player player) {
    // Check rows for winning moves
    for (int i = 0; i < 3; i++) {
      if (board[i][0] == player &&
          board[i][1] == player &&
          board[i][2] == Player.none) {
        return Point<int>(i, 2);
      }
      if (board[i][0] == player &&
          board[i][2] == player &&
          board[i][1] == Player.none) {
        return Point<int>(i, 1);
      }
      if (board[i][1] == player &&
          board[i][2] == player &&
          board[i][0] == Player.none) {
        return Point<int>(i, 0);
      }
    }

    // Check columns for winning moves
    for (int i = 0; i < 3; i++) {
      if (board[0][i] == player &&
          board[1][i] == player &&
          board[2][i] == Player.none) {
        return Point<int>(2, i);
      }
      if (board[0][i] == player &&
          board[2][i] == player &&
          board[1][i] == Player.none) {
        return Point<int>(1, i);
      }
      if (board[1][i] == player &&
          board[2][i] == player &&
          board[0][i] == Player.none) {
        return Point<int>(0, i);
      }
    }

    // Check diagonals for winning moves
    if (board[0][0] == player &&
        board[1][1] == player &&
        board[2][2] == Player.none) {
      return Point<int>(2, 2);
    }
    if (board[0][0] == player &&
        board[2][2] == player &&
        board[1][1] == Player.none) {
      return Point<int>(1, 1);
    }
    if (board[1][1] == player &&
        board[2][2] == player &&
        board[0][0] == Player.none) {
      return Point<int>(0, 0);
    }
    if (board[0][2] == player &&
        board[1][1] == player &&
        board[2][0] == Player.none) {
      return Point<int>(2, 0);
    }
    if (board[0][2] == player &&
        board[2][0] == player &&
        board[1][1] == Player.none) {
      return Point<int>(1, 1);
    }
    if (board[1][1] == player &&
        board[2][0] == player &&
        board[0][2] == Player.none) {
      return Point<int>(0, 2);
    }

    return null; // No winning move found
  }

//////////////////////////////////////////////////////////
  void _checkWinner() {
    // Check rows, columns, and diagonals for winning combinations
    for (int i = 0; i < 3; i++) {
      if (board[i][0] != Player.none &&
          board[i][0] == board[i][1] &&
          board[i][0] == board[i][2]) {
        winner = board[i][0];
      }
      if (board[0][i] != Player.none &&
          board[0][i] == board[1][i] &&
          board[0][i] == board[2][i]) {
        winner = board[0][i];
      }
    }
    if (board[0][0] != Player.none &&
        board[0][0] == board[1][1] &&
        board[0][0] == board[2][2]) {
      winner = board[0][0];
    }
    if (board[0][2] != Player.none &&
        board[0][2] == board[1][1] &&
        board[0][2] == board[2][0]) {
      winner = board[0][2];
    }
  }

  void _resetGame() {
    setState(() {
      board = List.generate(3, (_) => List.filled(3, Player.none));
      currentPlayer = Player.X;
      winner = Player.none;
      player1Controller.clear();
      player2Controller.clear();
      player1Name = '';
      player2Name = '';
      showPlayer1Form = false;
      showPlayer2Form = false;
      showBoard = false;
      _showOpponentSelection();
    });
  }

  String getPlayerSymbol(Player player) {
    switch (player) {
      case Player.X:
        return 'X';
      case Player.O:
        return 'O';
      default:
        return '';
    }
  }

  String getGameResult() {
    if (winner != Player.none) {
      if (!isAI) {
        return '${getPlayerName(winner)} won!';
      } else {
        return winner == Player.X ? 'You won!' : 'AI won!';
      }
    } else if (!board.any((row) => row.contains(Player.none))) {
      return 'Draw match!';
    } else {
      return '';
    }
  }

  String getPlayerName(Player player) {
    switch (player) {
      case Player.X:
        return player1Name.isNotEmpty ? player1Name : 'Player A';
      case Player.O:
        return player2Name.isNotEmpty ? player2Name : 'Player B';
      default:
        return '';
    }
  }
}

enum Player { none, X, O }
