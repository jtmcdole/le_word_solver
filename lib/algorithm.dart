import 'package:wordle_solver/words.dart';

/// Generate a score based on the letter frequency inside of it, counting each
/// letter only once unless [unique] is false.
int score(String word, {bool unique = true}) {
  int score = 0;

  if (unique) {
    for (var character in <String>{...word.split('')}) {
      score += letterFrequency[character]!;
    }
  } else {
    for (var character in word.split('')) {
      score += letterFrequency[character]!;
    }
  }
  return score;
}

List<String> resortWords(List<String> words) => [...words]..sort(
    (w1, w2) {
      final lf1 = score(w1, unique: true);
      final lf2 = score(w2, unique: true);
      return lf2.compareTo(lf1);
    },
  );

const w = CharacterState.wrong;
const f = CharacterState.found;
const s = CharacterState.somewhere;

List<CharacterState> parseGuess(String guess) {
  if (guess.length != 10) return [];

  final list = <CharacterState>[];
  for (int i = 0; i < 10; i += 2) {
    if (guess[i + 1] == '-') {
      list.add(w(guess[i]));
    } else if (guess[i + 1] == '+') {
      list.add(s(guess[i]));
    } else if (guess[i + 1] == '*') {
      list.add(f(guess[i]));
    } else {
      return [];
    }
  }
  return list;
}

List<String> solve(List<List<CharacterState>> guesses) {
  // first; make some regex eh?
  final nots = <String>{};
  final maybes = <String>{};
  for (var guess in guesses) {
    if (guess.length < 5) continue;
    for (var char in guess) {
      if (char.state == FoundState.wrong) {
        nots.add(char.character);
      } else if (char.state == FoundState.somewhere) {
        maybes.add(char.character);
      }
    }
  }

  final notGroup = nots.join('');
  final regexs = List<String>.filled(5, notGroup);
  findIndex(List<List<CharacterState>> guesses, int i, List<String> regex) {
    for (var guess in guesses) {
      if (guess.length <= i) continue;
      if (guess[i].state == FoundState.found) {
        regex[i] = guess[i].character;
        return;
      }
      if (guess[i].state == FoundState.wrong) continue;
      if (guess[i].state == FoundState.somewhere) {
        regex[i] = '${regex[i]}${guess[i].character}';
      }
    }
    regex[i] = '[^${regex[i]}]';
  }

  // cspell:ignore regexs
  findIndex(guesses, 0, regexs);
  findIndex(guesses, 1, regexs);
  findIndex(guesses, 2, regexs);
  findIndex(guesses, 3, regexs);
  findIndex(guesses, 4, regexs);

  // print(regexs.join(''));
  final regex = RegExp(regexs.join(''));
  final firstMatches = [
    ...sortedWords.where((element) => regex.hasMatch(element))
  ];
  if (maybes.isNotEmpty) {
    final nextGuess = [
      ...firstMatches
          .where((match) => maybes.every((maybe) => match.contains(maybe)))
    ];
    return nextGuess;
  } else {
    return firstMatches;
  }
}

enum FoundState { wrong, somewhere, found }

class CharacterState {
  final String character;
  FoundState state;

  CharacterState(this.character, {this.state = FoundState.wrong});

  CharacterState.wrong(this.character) : state = FoundState.wrong;
  CharacterState.somewhere(this.character) : state = FoundState.somewhere;
  CharacterState.found(this.character) : state = FoundState.found;

  @override
  String toString() =>
      '$character${state == FoundState.found ? '◆' : state == FoundState.somewhere ? '◈' : '◇'}';
}
