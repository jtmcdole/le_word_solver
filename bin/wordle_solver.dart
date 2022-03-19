import 'package:wordle_solver/algorithm.dart';

main(List<String> args) {
  final guesses = [for (var arg in args) parseGuess(arg)];
  // ignore: avoid_print
  print(guesses);

  // ignore: avoid_print
  print(solve(guesses));
}
