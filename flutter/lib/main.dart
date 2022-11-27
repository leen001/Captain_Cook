import 'dart:convert';

import 'package:captain_cook/api.dart';
import 'package:captain_cook/widgets/IngredientSelector.dart';
import 'package:captain_cook/widgets/SearchBar.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

import 'states.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => AvailableIngredients(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Captain Cook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _loadingCatFact = true;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<void> _handleSignIn() async {
    try {
      GoogleSignInAccount? user = await _googleSignIn.signIn();
      print(user);
    } catch (error) {
      print(error);
    }
  }

  void _openSettings() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Settings"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text("Settings will be implemented soon"),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Icon(Icons.copyright_outlined),
                    Text(" 2022 Captain Cook"),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Version, etc. (coming soon)"),
                        ),
                      ),
                  icon: const Icon(Icons.info_outline),
                  label: const Text("About")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Close"))
            ],
            actionsAlignment: MainAxisAlignment.spaceBetween,
          );
        });
  }

  void _openIngredientSelector() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IngredientSelector()),
    );
  }

  Future<CatFact> _getCatFact() async {
    try {
      final response = await http.get(Uri.parse('https://catfact.ninja/fact'));

      if (response.statusCode == 200) {
        return CatFact.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load cat fact');
      }
    } catch (e) {
      return CatFact("Failed to load cat fact", 0);
    }
  }

  Widget _buildCatFactWidget(CatFact catFact) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                MdiIcons.cat,
                size: 30,
                color: Colors.orangeAccent,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "Did you know?",
                style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            catFact.fact,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(
            height: 20,
          ),
          IconButton(
              onPressed: (_loadingCatFact)
                  ? null
                  : () => setState(() {
                        _loadingCatFact = true;
                      }),
              tooltip: "Get another fact",
              icon: const Icon(MdiIcons.chevronDownCircleOutline))
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Text("Captain"),
            Icon(MdiIcons.chefHat),
            Text("Cook"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Card(
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Consumer<AvailableIngredients>(
                  builder: (context, availableIngredients, child) => Center(
                      child: Text((availableIngredients.length > 0)
                          ? availableIngredients.all
                              .map((e) => e.id)
                              .toList()
                              .toString()
                          : "Please select your ingredients")),
                ),
              ),
            ),
          ),
          Card(
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      "Login",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: _handleSignIn,
                      child: const Text("Sign in with Google"),
                    ),
                  ],
                ),
              )),
          FutureBuilder<CatFact>(
            future: _getCatFact(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _loadingCatFact = false;
                return _buildCatFactWidget(snapshot.data!);
              } else if (snapshot.hasError) {
                _loadingCatFact = false;
                return Text("${snapshot.error}");
              }
              // By default, show a loading spinner.
              _loadingCatFact = true;
              return const LinearProgressIndicator();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openIngredientSelector,
        tooltip: 'Select ingredients',
        heroTag: "ingredient_selector_open",
        isExtended: true,
        child: const Icon(Icons.playlist_add_check),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class RecipeList extends StatefulWidget {
  const RecipeList({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<RecipeList> createState() => _RecipeListState();
}

// UNUSED!!!
class _RecipeListState extends State<RecipeList> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void navigateToSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SearchBar()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the RecipeList object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              navigateToSearch(context);
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            height: 100,
            padding: const EdgeInsets.all(10),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Row(
                  children: [
                    Image.network(
                      'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.fastfoodmenunutrition.com%2Fwp-content%2Fuploads%2F2015%2F03%2Ffast-food.jpg&f=1&nofb=1&ipt=220941f0d45b9cdf925535c2e00f64583829e2365e1a5659a0ca93ff2a3460a4&ipo=images',
                      fit: BoxFit.fill,
                    ),
                    // spacing
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Text(
                        'Hamburger',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rate_rounded,
                            color: Colors.yellow,
                            size: 40,
                            shadows: [
                              Shadow(
                                blurRadius: 15.0,
                                color: Colors.black,
                              ),
                            ]),
                        const Icon(Icons.star_rate_rounded,
                            color: Colors.yellow,
                            size: 40,
                            shadows: [
                              Shadow(
                                blurRadius: 15.0,
                                color: Colors.black,
                              ),
                            ]),
                        const Icon(Icons.star_rate_rounded,
                            color: Colors.yellow,
                            size: 40,
                            shadows: [
                              Shadow(
                                blurRadius: 15.0,
                                color: Colors.black,
                              ),
                            ]),
                        const Icon(Icons.star_rate_rounded,
                            color: Colors.yellow,
                            size: 40,
                            shadows: [
                              Shadow(
                                blurRadius: 15.0,
                                color: Colors.black,
                              ),
                            ]),
                        Icon(Icons.star_rate_rounded,
                            color: Colors.grey[300],
                            size: 40,
                            shadows: const [
                              Shadow(
                                blurRadius: 15.0,
                                color: Colors.black,
                              ),
                            ]),
                      ],
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        // TODO: add to favorites
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to favorites'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: <Widget>[
          //     const Text(
          //       'You have pushed the button this many times:',
          //     ),
          //     Text(
          //       '$_counter',
          //       style: Theme.of(context).textTheme.headline4,
          //     ),
          //   ],
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.list_alt),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
