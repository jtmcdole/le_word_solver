import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wordle_solver/words.dart';

void main() {
  if (kDebugMode) {
    print(letterFrequency);

    int score(String word, {bool unique = false}) {
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

    // words.sort((w1, w2) {
    //   final lf1 = score(w1);
    //   final lf2 = score(w2);
    //   return lf2.compareTo(lf1);
    // });

    // sorted unique-character worth.
    final sortedWords = [...words]..sort((w1, w2) {
        final lf1 = score(w1, unique: true);
        final lf2 = score(w2, unique: true);
        return lf2.compareTo(lf1);
      });
    print(sortedWords);
    print(words.length);
    print(sortedWords.length);

    const c = CharacterState.new;

    final guesses = <List<CharacterState>>[
      [
        c('r', state: FoundState.wrong),
        c('a', state: FoundState.wrong),
        c('i', state: FoundState.wrong),
        c('s', state: FoundState.wrong),
        c('e', state: FoundState.wrong)
      ],
    ];
    print(guesses);

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
    print(score('alert', unique: true) + score('sonic', unique: true));
    print(score('raise', unique: true) + score('donut', unique: true));
    print(score('raise', unique: true) + score('clout', unique: true));
    print(score('arose', unique: true) + score('until', unique: true));
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

    print(regexs.join(''));
    final regex = RegExp(regexs.join(''));
    final firstMatches = [
      ...sortedWords.where((element) => regex.hasMatch(element))
    ];
    print('firstMatches: $firstMatches');
    if (maybes.isNotEmpty) {
      print([
        ...firstMatches
            .where((match) => maybes.every((maybe) => match.contains(maybe)))
      ]);
    }
  }

  runApp(const WordleSolver());
}

/// - layout: 5 selectors. text box for the word - forget rendering a keyboard
/// - tap to toggle result
/// - list options. under
///
/// should we rank options based off some frequency?
///   - frequency overall in words
///   - frequency of letter in position
///
/// filters:
///   - letters no where - ignore at all locations
///   - letters somewhere || letters found - options to split at a location in a ternary
///   - found position: can only be this one letter.
///
/// Step 1: just build a regex
/// Step 2: performance test
/// Step 3: ternary.

class WordleSolver extends StatelessWidget {
  const WordleSolver({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordle Solver',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum FoundState { wrong, somewhere, found }

class CharacterState {
  final String character;
  FoundState state;

  CharacterState(this.character, {this.state = FoundState.wrong});

  @override
  String toString() =>
      '$character${state == FoundState.found ? '◆' : state == FoundState.somewhere ? '◈' : '◇'}';
}

class _MyHomePageState extends State<MyHomePage> {
  final rows = <List<CharacterState>>[];

  @override
  Widget build(BuildContext context) {
    // This trailing comma makes auto-formatting nicer for build methods.
    return Container();
  }
}
