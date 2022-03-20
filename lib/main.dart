import 'package:flutter/material.dart';
import 'package:wordle_solver/algorithm.dart';

void main() {
  runApp(const WordleSolver());
}

final key = GlobalKey<MyHomePageState>();

/// - layout: 5 selectors. text box for the word - forget rendering a keyboard
/// - tap to toggle result
/// - list options. under
class WordleSolver extends StatelessWidget {
  const WordleSolver({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordle Solver',
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
      home: Scaffold(
        backgroundColor: Colors.black,
        body: MyHomePage(title: 'Wordle Solver', key: key),
      ),
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

  @override
  Widget build(BuildContext context) {
    // This trailing comma makes auto-formatting nicer for build methods.
    final list = ListView(
      shrinkWrap: true,
      children: [
        for (var row in rows)
          Row(
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
      ],
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: list),
        SizedBox(
          width: 200,
          child: TextField(
            controller: controller,
            autocorrect: false,
            autofocus: false,
            decoration: InputDecoration(
              hintText: 'enter 5 letter words',
              errorText: errorText,
            ),
            onSubmitted: (String text) {
              setState(() {
                if (text.length != 5) {
                  controller.clear();
                  errorText = 'Word must be 5 characters long';
                  return;
                }
                errorText = null;
                rows.add([
                  CharacterState(text[0], state: FoundState.wrong),
                  CharacterState(text[1], state: FoundState.wrong),
                  CharacterState(text[2], state: FoundState.wrong),
                  CharacterState(text[3], state: FoundState.wrong),
                  CharacterState(text[4], state: FoundState.wrong),
                ]);
                controller.clear();
                suggestions = solve(rows);
              });
            },
          ),
        ),
        Flexible(
          child: ListView(
            padding: const EdgeInsets.only(top: 10),
            children: [
              for (var sug in suggestions) Center(child: Text(sug)),
            ],
          ),
        ),
      ],
    );
  }
}
