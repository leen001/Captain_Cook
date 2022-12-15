import 'package:captain_cook/widgets/selected_ingredients.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'states.dart';
import 'widgets/shopping_list.dart';
import 'widgets/recipe_list.dart';
import 'widgets/auto_complete_ingredients.dart';
import 'widgets/google_auth_status.dart';

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
      MaterialPageRoute(builder: (context) => const Shoppinglist()),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: Column(
                        children: <Widget>[
                          const SelectedIngredients(
                            dismissable: true,
                          ),
                          Consumer<AvailableIngredients>(
                              builder: (context, value, child) => Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Expanded(
                                                    child:
                                                        AutoCompleteIngredients()),
                                                IconButton(
                                                    onPressed: () {
                                                      _openRecipeOutput();
                                                    },
                                                    icon: const Icon(
                                                        Icons.search),
                                                    color: Colors.indigo),
                                              ]
                                              //  Text(value.selected
                                              //     .map((e) => e)
                                              //     .toList()
                                              //     .toString()),
                                              ),
                                        ),
                                      ),
                                    ],
                                  )),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const GoogleAuthStatus(),
        ],
      ),
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
