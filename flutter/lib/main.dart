import 'package:captain_cook/api.dart';
import 'package:captain_cook/widgets/Shoppinglist.dart';
import 'package:captain_cook/widgets/Recipe_Output.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'states.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => AvailableIngredients()),
    ChangeNotifierProvider(create: (context) => AuthenticatedUser()),
  ], builder: (context, child) => const MyApp()));
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

  // void _openIngredientSelector() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => IngredientSelector()),
  //   );
  // }

  void _openRecipeOutput() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const RecipeList(
                selectedIngredients: [],
              )),
    );
  }

  void _openshoppinglist() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Shoppinglist(name: 'test', checked: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
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
            child: SingleChildScrollView(
              primary: true,
              child: Column(
                children: [
                  Card(
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Consumer<AvailableIngredients>(
                        builder: (context, availableIngredients, child) =>
                            Center(
                          // child: Text((availableIngredients.length > 0)
                          //     ? availableIngredients.all
                          //         .map((e) => e.id)
                          //         .toList()
                          //         .toString()
                          //     : "Please select your ingredients")
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: Column(
                              children: <Widget>[
                                Consumer<AvailableIngredients>(
                                  builder: (context, value, child) => Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        child: Text(value.selected
                                            .map((e) => e)
                                            .toList()
                                            .toString()),
                                      ),
                                    ],
                                  ),
                                ),
                                const AutoCompleteIngredients(),
                                IconButton(
                                    onPressed: () {
                                      _openRecipeOutput();
                                    },
                                    icon: const Icon(Icons.search),
                                    color: Colors.indigo),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],

                              ///HERE
                              //     TextFormField(
                              //   decoration: const InputDecoration(
                              //     border: UnderlineInputBorder(),
                              //     labelText: 'Search Recipe',
                              //   ),
                              // ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Consumer<AuthenticatedUser>(
                      builder: (context, googleAuth, child) => Card(
                          elevation: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: FutureBuilder(
                              future: googleAuth.isSignedIn,
                              builder: (context, snapshot) => (snapshot.hasData)
                                  ? (snapshot.data as bool)
                                      ? Column(children: [
                                          FutureBuilder(
                                            future: googleAuth.user,
                                            builder: (context, user) =>
                                                RichText(
                                              text: TextSpan(
                                                text: "Logged in as ",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                                children: [
                                                  (user.hasData &&
                                                          user.data != null)
                                                      ? TextSpan(
                                                          text: (user.data
                                                                  as GoogleSignInAccount)
                                                              .displayName,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))
                                                      : const TextSpan(
                                                          text: "Unknown",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          ElevatedButton(
                                              onPressed: () async {
                                                await googleAuth.signOut();
                                              },
                                              child: const Text("Sign out"))
                                        ])
                                      : Column(children: [
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
                                              onPressed: () async {
                                                await googleAuth.signIn();
                                              },
                                              child: const Text("Sign in")),
                                          (googleAuth.hasError)
                                              ? Text(
                                                  googleAuth.error,
                                                  style: const TextStyle(
                                                      color: Colors.red),
                                                )
                                              : const SizedBox()
                                        ])
                                  : const Center(
                                      child: SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                            ),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton:
      //     Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      //   FloatingActionButton(
      //     onPressed: _openIngredientSelector,
      //     tooltip: 'Select ingredients',
      //     heroTag: "ingredient_selector_open",
      //     isExtended: true,
      //     child: const Icon(Icons.check_box),
      //   ), // This trailing comma makes auto-formatting nicer for build methods.
      // const SizedBox(
      //   height: 10,
      // ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _openshoppinglist,
            tooltip: 'Shopping List',
            heroTag: "shopping_list_open",
            isExtended: true,
            child: const Icon(Icons.playlist_add_check),
          ),
        ],
      ),
    );
  }
}

class AutoCompleteIngredients extends StatefulWidget {
  const AutoCompleteIngredients({super.key});

  @override
  State<AutoCompleteIngredients> createState() =>
      _AutoCompleteIngredientsState();
}

class _AutoCompleteIngredientsState extends State<AutoCompleteIngredients> {
  String _displayStringForOption(String option) => option;

  @override
  Widget build(BuildContext context) {
    AvailableIngredients ingredients =
        Provider.of<AvailableIngredients>(context);
    if (ingredients.isEmpty) {
      ingredients.loadFromApi(CCApi().getPossibleIngredients);
    }
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        } else {
          return ingredients.names.where((String option) {
            return option.contains(textEditingValue.text.toLowerCase());
          });
        }
        // if (AvailableIngredients.contains( option)) {
        //   return option.contains(textEditingValue.text.toLowerCase());
        // }
        // return AvailableIngredients.contains((String option) {
        //   return option.contains(textEditingValue.text.toLowerCase());
        // },);
      },
      onSelected: (String selection) {
        // Consumer<SelectedIng>(
        //   builder: (context, selectedIng, child) => selectedIng.add(selection),
        // );
        ingredients.select(selection);

        //Navigator.pop(context, selection);
        return;
      },
    );
  }

  void _returnToStart(String selectedIngredient) {
    //remove the text in input field
    //AvailableIngredients.remove(selectedIngredient);
  }

//   void _startRecipeOutput() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => RecipeList(_selectedIngredients)),
//     );
}
