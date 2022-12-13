import 'dart:convert';
import 'dart:html';
//import 'dart:ffi';

import 'package:captain_cook/api.dart';
import 'package:captain_cook/widgets/IngredientSelector.dart';
import 'package:captain_cook/widgets/SearchBar.dart';
import 'package:captain_cook/widgets/Shoppinglist.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

import 'states.dart';

const API_BASE_URL = String.fromEnvironment('API_BASE_URL',
    defaultValue: 'http://localhost:3000');

void main() {
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
  bool _loadingCatFact = true;
  List<dynamic> list_ingredients = [];
  List<dynamic> list_recipes = [];
  Color _favIconColor = Colors.grey;

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

  void _openshoppinglist() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Shoppinglist(name: 'test', checked: false)),
    );
  }

  Future<List<Recipe>> _getRecipes() async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/recipes'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'count': 2,
          'ingredients': [""],
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to load recipes');
      }
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<Recipe> recipes = [];
      for (final recipe in json['recipes']) {
        recipes.add(Recipe.fromJson(recipe));
      }
      return recipes;
    } catch (e) {
      print(e);
      return [];
    }
  }

  List<Widget> _buildRecipeWidgets(List<Recipe> recipes) {
    List<Widget> recipeWidgets = [];

    for (final recipe in recipes) {
      //print("recipe ${recipe.uid}");
      recipeWidgets.add(
        Card(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 40, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      recipe.recipe,
                      style: const TextStyle(
                          fontSize: 30, height: 3, fontWeight: FontWeight.bold),
                    ),
                    const Icon(
                      Icons.done_rounded,
                      color: Colors.green,
                      size: 30,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 10, 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Flexible(
                            flex: 2,
                            fit: FlexFit.loose,
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                for (var i = 0;
                                    i < recipe.ingredients.length;
                                    i++)
                                  ListTile(
                                    title: Text(recipe.ingredients[i]),
                                    trailing: IconButton(
                                      splashRadius: 20,
                                      splashColor: Colors.green,
                                      focusColor: Colors.green,
                                      color: _favIconColor,
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                      onPressed: () {},
                                      highlightColor: Colors.green,

                                      // setState(() {
                                      //   if (_favIconColor == Colors.grey) {
                                      //     //_openSettings;
                                      //     _favIconColor = Colors.red;
                                      //   } else {
                                      //     _favIconColor = Colors.grey;
                                      //   }
                                      //   //HERE get the add ingredient Selector plus pop up
                                      // });
                                      // }
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const VerticalDivider(
                            color: Colors.black,
                            thickness: 1,
                            indent: 20,
                            endIndent: 20,
                          ),
                          Flexible(
                            flex: 5,
                            fit: FlexFit.loose,
                            child:
                                //Text(recipe.r_direction),
                                ListView(
                              shrinkWrap: true,
                              children: [
                                for (var i = 0;
                                    i < recipe.r_direction.length;
                                    i++)
                                  ListTile(
                                    title: Text(recipe.r_direction[i]),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Flexible(
                            flex: 2,
                            fit: FlexFit.loose,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                for (var i = 0;
                                    i < recipe.r_nutrition_info.length;
                                    i++)
                                  Text(recipe.r_nutrition_info[i]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            flex: 2,
                            fit: FlexFit.loose,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  "Cooking Time ${recipe.cooking_time}",
                                ),
                                Text("Total Time ${recipe.total_time}"),
                                Text(
                                    "Recipe Servings ${recipe.recipe_servings}"),
                                //Text("Recipe yield ${recipe.recipe_yield}")
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    print("widget length ${recipeWidgets.length}");
    return recipeWidgets;
  }

  // @override
  // Widget build(BuildContext) {
  //   return IconButton(
  //       icon: Icon(Icons.star, color: _favIconColor),
  //       onPressed: () {
  //         setState(() {
  //         _favIconColor = Colors.green;
  //       });
  //     },
  //   );
  // }

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
                              const Center(
                            // child: Text((availableIngredients.length > 0)
                            //     ? availableIngredients.all
                            //         .map((e) => e.id)
                            //         .toList()
                            //         .toString()
                            //     : "Please select your ingredients")
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 16),
                                child: AutocompleteBasicExample()

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
                    FutureBuilder<List<Recipe>>(
                      future: _getRecipes(),
                      builder: (context, snapshot) {
                        // if (snapshot.hasData) {
                        //   final children = <Widget>[];
                        //   for (var i = 0; i < list.length; i++) {
                        //     children.add(ListTile(
                        //       title: Text(list[i]),
                        //     ));
                        //   }
                        //   return ListView(
                        //     shrinkWrap: true,
                        //     children: children,
                        //   );
                        // } else if (snapshot.hasError) {
                        //   return Text("${snapshot.error}");
                        // }
                        // return const LinearProgressIndicator();

                        if (snapshot.hasData) {
                          return Column(
                            children: _buildRecipeWidgets(snapshot.data!),
                          );
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        return const LinearProgressIndicator();
                      },
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
                                builder: (context, snapshot) => (snapshot
                                        .hasData)
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
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            onPressed: _openIngredientSelector,
            tooltip: 'Select ingredients',
            heroTag: "ingredient_selector_open",
            isExtended: true,
            child: const Icon(Icons.check_box),
          ), // This trailing comma makes auto-formatting nicer for build methods.
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            onPressed: _openshoppinglist,
            tooltip: 'Shopping List',
            heroTag: "shopping_list_open",
            isExtended: true,
            child: const Icon(Icons.playlist_add_check),
          ),
        ]));
  }
}

class AutocompleteBasicExample extends StatelessWidget {
  const AutocompleteBasicExample({super.key});

  static const List<String> _kOptions = <String>[
    'tomato',
    'onion',
    'potato',
    'banana',
  ];

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return _kOptions.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        //return _addIngredient(selection);
      },
    );
  }
}

//set state for the list of ingredients

class RecipeList extends StatefulWidget {
  const RecipeList({super.key, required this.title});

  final String title;

  @override
  State<RecipeList> createState() => _RecipeListState();
}

// UNUSED!!!
class _RecipeListState extends State<RecipeList> {
  List<String> ingredients = [];

  void _addIngredient(String ingredient) {
    setState(() {
      ingredients.add(ingredient);
    });
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      ingredients.remove(ingredient);
    });
  }

  // void _openIngredientSelector() {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //         builder: (context) => IngredientSelector(
  //               addIngredient: _addIngredient,
  //               removeIngredient: _removeIngredient,
  //             )),
  //   );
  // }

  // void _openshoppinglist() {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //         builder: (context) => ShoppingList(
  //               ingredients: ingredients,
  //             )),
  //   );
  // }
  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }

  void navigateToSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SearchBar()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.list_alt),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
