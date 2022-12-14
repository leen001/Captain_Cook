import 'dart:convert';
import 'dart:math';
import 'package:captain_cook/states.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:captain_cook/api.dart';
import 'package:captain_cook/main.dart';
import 'package:material_design_icons_flutter/icon_map.dart';
import 'package:provider/provider.dart';

class RecipeList extends StatefulWidget {
  const RecipeList({Key? key, required this.selectedIngredients})
      : super(key: key);
  final String title = 'Recipe List';
  final List<String> selectedIngredients;

  @override
  _RecipeListState createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  List<String> ingredients = [];
  List<RecipeList> list_recipes = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _navigateToSearch(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                Container(
                  // height: 100,
                  // width: 100,
                  padding: const EdgeInsets.all(10),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: SingleChildScrollView(
                        child: Row(children: [
                          FutureBuilder<List<Recipe>>(
                            future: _getRecipes(context),
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
                                return Expanded(
                                  child: Column(
                                    children:
                                        _buildRecipeWidgets(snapshot.data!),
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              }
                              return const Icon(Icons
                                  .circle); //const LinearProgressIndicator();

                              // return Column(
                              //   children: _buildRecipeWidgets(snapshot.data!),
                              // );
                            },
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToSearch(context);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.list_alt),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _navigateToSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MainApp()),
    );
  }

  Future<List<Recipe>> _getRecipes(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/recipes'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'count': 3,
          'ingredients': Provider.of<SelectedIng>(context, listen: false).all,
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
                                      color: Colors.green,
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
}
