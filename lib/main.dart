import 'package:flutter/material.dart';
import 'package:le_word_solver/algorithm.dart';
import 'package:le_word_solver/words.dart';

void main() {
  runApp(const LeWordSolver());
}

final key = GlobalKey<MyHomePageState>();

/// - layout: 5 selectors. text box for the word - forget rendering a keyboard
/// - tap to toggle result
/// - list options. under
class LeWordSolver extends StatelessWidget {
  const LeWordSolver({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'le\'Word Solver',
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyText1: TextStyle(fontSize: 16.0),
          bodyText2: TextStyle(fontSize: 24.0),
        ),
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
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
      ),
      home: MyHomePage(title: 'le\'Word Solver', key: key),
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
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final rows = <List<CharacterState>>[
    // parseGuess('r-a-i-s-e-'),
    // parseGuess('c-l-o-u-t-'),
    // [
    //   CharacterState('', state: FoundState.unknown),
    //   CharacterState('', state: FoundState.unknown),
    //   CharacterState('', state: FoundState.unknown),
    //   CharacterState('', state: FoundState.unknown),
    //   CharacterState('', state: FoundState.unknown),
    // ],
  ];
  List<String> suggestions = [];
  final colors = {
    FoundState.found: Colors.green[600],
    FoundState.somewhere: Colors.yellow[700],
    FoundState.wrong: Colors.grey[850],
    FoundState.unknown: Colors.black,
  };

  @override
  void initState() {
    super.initState();
    suggestions = solve(rows);
  }

  final controller = TextEditingController();
  String? errorText;

  void addText(String text) {
    setState(() {
      if (text.length != 5) {
        controller.clear();
        errorText = 'Word must be 5 characters long';
        return;
      }
      errorText = null;
      final newCharacters = <CharacterState>[];
      for (int i = 0; i < 5; i++) {
        // look for "founds" and "maybes". "Maybes" can be anywhere, but founds
        // outrank.
        var state = FoundState.wrong;
        final maybes = <String>{};

        for (var row in rows) {
          for (var char in row) {
            if (char.state == FoundState.somewhere) {
              maybes.add(char.character);
            }
          }
        }

        for (var row in rows) {
          if (text[i] == row[i].character && row[i].state == FoundState.found) {
            state = FoundState.found;
            break;
          }
        }
        if (state != FoundState.found && maybes.contains(text[i])) {
          state = FoundState.somewhere;
        }

        newCharacters.add(CharacterState(text[i], state: state));
      }
      rows.add(newCharacters);
      controller.clear();
      suggestions = solve(rows);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This trailing comma makes auto-formatting nicer for build methods.
    final list = ListView.builder(
      shrinkWrap: true,
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        final string = [for (var char in row) char.character].join();
        return Dismissible(
          key: Key(string),
          background: Container(color: Colors.red[600]),
          onDismissed: (_) {
            setState(() {
              rows.removeAt(index);
              suggestions = solve(rows);

              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text('Removed $string'),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      setState(() {
                        rows.insert(index, row);
                        suggestions = solve(rows);
                      });
                    },
                  ),
                ));
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var char in row)
                Card(
                  child: GestureDetector(
                    onTap: () {
                      if (char.state == FoundState.unknown &&
                          char.character == '') return;
                      setState(() {
                        char.state = FoundState.values[
                            ((char.state.index + 1) % FoundState.values.length)
                                .clamp(1, FoundState.values.length)];
                        suggestions = solve(rows);
                      });
                    },
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors[char.state] ?? Colors.black,
                          border: char.state == FoundState.unknown
                              ? Border.all(
                                  color: Colors.grey[850]!,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(char.character),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 50)),
          Flexible(child: list),
          SizedBox(
            width: 200,
            child: TextField(
              controller: controller,
              autocorrect: false,
              enableSuggestions: false,
              maxLength: 5,
              autofocus: false,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'enter 5 letter words',
                errorText: errorText,
              ),
              onChanged: (String? text) {
                if (text == null) return;
                if (text.length == 5) addText(text);
              },
              onSubmitted: addText,
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              primary: false, // scroll controller attached multiple times?
              padding: const EdgeInsets.only(top: 10),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return InkWell(
                  child: Center(child: Text(suggestion)),
                  onTap: () {
                    addText(suggestion);
                  },
                );
              },
            ),
          ),
          SizedBox(
            width: 200,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${suggestions.length}/${words.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
