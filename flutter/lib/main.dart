import 'dart:convert';
//import 'dart:ffi';

import 'package:captain_cook/api.dart';
import 'package:captain_cook/widgets/IngredientSelector.dart';
import 'package:captain_cook/widgets/SearchBar.dart';
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

  //List<Map<String, dynamic>> list = [];
  List<dynamic> list_ingredients = [];
  List<dynamic> list_recipes = [];

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

  // Future<CatFact> _getCatFact() async {
  //   try {
  //     final response = await http.get(Uri.parse('https://catfact.ninja/fact'));

  //     if (response.statusCode == 200) {
  //       return CatFact.fromJson(jsonDecode(response.body));
  //     } else {
  //       throw Exception('Failed to load cat fact');
  //     }
  //   } catch (e) {
  //     return CatFact("Failed to load cat fact", 0);
  //   }
  // }

  Future<List<Recipe>> _getRecipes() async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/recipes'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'count': 2,
          'ingredients': ["tomato"],
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

  // Widget _buildCatFactWidget(CatFact catFact) {
  //   return Card(
  //     elevation: 10,
  //     child: Padding(
  //       padding: const EdgeInsets.all(15.0),
  //       child: Column(children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             const Icon(
  //               MdiIcons.cat,
  //               size: 30,
  //               color: Colors.orangeAccent,
  //             ),
  //             const SizedBox(
  //               width: 10,
  //             ),
  //             Text(
  //               "Did you know?",
  //               style: TextStyle(
  //                   fontSize: 20,
  //                   color: Theme.of(context).primaryColor,
  //                   fontWeight: FontWeight.bold),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(
  //           height: 10,
  //         ),
  //         Text(
  //           catFact.fact,
  //           textAlign: TextAlign.center,
  //           style: const TextStyle(fontSize: 16),
  //         ),
  //         const SizedBox(
  //           height: 20,
  //         ),
  //         IconButton(
  //             onPressed: (_loadingCatFact)
  //                 ? null
  //                 : () => setState(() {
  //                       _loadingCatFact = true;
  //                     }),
  //             tooltip: "Get another fact",
  //             icon: const Icon(MdiIcons.chevronDownCircleOutline))
  //       ]),
  //     ),
  //   );
  // }

  List<Widget> _buildRecipeWidgets(List<Recipe> recipes) {
    List<Widget> recipeWidgets = [];
    for (final recipe in recipes) {
      print("recipe ${recipe.uid}");
      recipeWidgets.add(
        Card(
            child: SingleChildScrollView(
          child: Column(
            children: [
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
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (var i = 0; i < recipe.ingredients.length; i++)
                          ListTile(
                            title: Text(recipe.ingredients[i]),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child:
                        //Text(recipe.r_direction),
                        ListView(
                      shrinkWrap: true,
                      children: [
                        for (var i = 0; i < recipe.r_direction.length; i++)
                          ListTile(
                            title: Text(recipe.r_direction[i]),
                          ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        )),
      );
    }
    print("widget length ${recipeWidgets.length}");
    return recipeWidgets;
    // children = <Widget>[
    //   // for (var i = 0; i < list.length; i++)
    //   //   ListTile(
    //   //     title: Text(list[i]),
    //   //   ),
    //   const Icon(
    //     Icons.done_rounded,
    //     color: Colors.green,
    //     size: 30,
    //   ),

    //   ListView(
    //     shrinkWrap: true,
    //     children: [
    //       for (var i = 0; i < list.length; i++)
    //         ListTile(
    //           title: Text(list[i]),
    //         ),
    //     ],
    //   ),
    //   //Text(snapshot.data!.ingredients.split(',').toString())
    //   //list =(snapshot.data!.ingredients.split(',')),
    //   //list.forEach((String age) => print(age));
    // ];
    // return Card(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: children,
    //     ),
    // );
    //return Text(snapshot.data!.ingredients);
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
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Enter your ingredients',
                              ),
                            ),
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

                      //List<Widget> children;
                      if (snapshot.hasData) {
                        return Column(
                          // padding: const EdgeInsets.all(8),
                          children: _buildRecipeWidgets(snapshot.data!),
                        );
                        //

                        //return ListView.builder(itemBuilder: _buildRecipeWidget(snapshot.data![))

                        // Recipe recipe = snapshot.data![0];
                        // return Card(
                        //     child: SingleChildScrollView(
                        //   child: Column(
                        //     children: [
                        //       Text(
                        //         recipe.recipe,
                        //         style: const TextStyle(
                        //             fontSize: 30,
                        //             height: 3,
                        //             fontWeight: FontWeight.bold),
                        //       ),
                        //       const Icon(
                        //         Icons.done_rounded,
                        //         color: Colors.green,
                        //         size: 30,
                        //       ),
                        //       Row(
                        //         children: <Widget>[
                        //           Expanded(
                        //             flex: 2,
                        //             child: ListView(
                        //               shrinkWrap: true,
                        //               children: [
                        //                 for (var i = 0;
                        //                     i < recipe.ingredients.length;
                        //                     i++)
                        //                   ListTile(
                        //                     title: Text(recipe.ingredients[i]),
                        //                   ),
                        //               ],
                        //             ),
                        //           ),
                        //           Expanded(
                        //             flex: 4,
                        //             child:
                        //                 //Text(recipe.r_direction),
                        //                 ListView(
                        //               shrinkWrap: true,
                        //               children: [
                        //                 for (var i = 0;
                        //                     i < recipe.r_direction.length;
                        //                     i++)
                        //                   ListTile(
                        //                     title: Text(recipe.r_direction[i]),
                        //                   ),
                        //               ],
                        //             ),
                        //           ),
                        //         ],
                        //       )
                        //     ],
                        //   ),
                        // ));
                        // // children = <Widget>[
                        // //   // for (var i = 0; i < list.length; i++)
                        // //   //   ListTile(
                        // //   //     title: Text(list[i]),
                        // //   //   ),
                        // //   const Icon(
                        // //     Icons.done_rounded,
                        // //     color: Colors.green,
                        // //     size: 30,
                        // //   ),

                        // //   //   ListView(
                        //   //     shrinkWrap: true,
                        //   //     children: [
                        //   //       for (var i = 0; i < list.length; i++)
                        //   //         ListTile(
                        //   //           title: Text(list[i]),
                        //   //         ),
                        //   //     ],
                        //   //   ),
                        //   //   //Text(snapshot.data!.ingredients.split(',').toString())
                        //   //   //list =(snapshot.data!.ingredients.split(',')),
                        //   //   //list.forEach((String age) => print(age));
                        //   // ];
                        //   // return Card(
                        //   //     child: Column(
                        //   //       mainAxisAlignment: MainAxisAlignment.center,
                        //   //       children: children,
                        //   //     ),
                        //   // );
                        //   //return Text(snapshot.data!.ingredients);
                        // }
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
          // Card(
          //   child:

          // ),
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

  final String title;

  @override
  State<RecipeList> createState() => _RecipeListState();
}

// Future<RecipeTest> _getRecipes() async {
//     try {
//       _counter = 3;

//       ingredients = ["onions"];

//       http.post(
//         Uri.parse('http:/localhost:60034/recipes'),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode({
//           'counter': _counter,
//           'ingredients': ingredients,
//         }),
//       );

//       final response = await http.get(
//         Uri.parse('http:/localhost:60034/recipes'),
//       );

//       if (response.statusCode == 200) {
//         return RecipeTest.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception('Failed to load cat fact');
//       }
//     } catch (e) {
//       return RecipeTest("Failed to load recipes");
//     }
//   }

// UNUSED!!!
class _RecipeListState extends State<RecipeList> {
  int _counter = 0;
  List<String> ingredients = [];

  void _incrementCounter() {
    setState(() {
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
