import 'package:captain_cook/states.dart';
import 'package:flutter/material.dart';
import 'package:captain_cook/api.dart';
import 'package:provider/provider.dart';

import 'selected_ingredients.dart';

class RecipeList extends StatefulWidget {
  const RecipeList({Key? key, required this.selectedIngredients})
      : super(key: key);
  final String title = 'Recipe List';
  final List<String> selectedIngredients;

  @override
  _RecipeListState createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  List<RecipeListItem> _recipeListItems = <RecipeListItem>[];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;
    _getRecipes(context).then((_) {
      // setState(() {
      //   _recipeListItems[0].expanded = true;
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: SingleChildScrollView(
                      child: Column(children: [
                        const SelectedIngredients(
                          dismissable: true,
                        ),
                        const SizedBox(height: 10),
                        Builder(builder: (context) {
                          if (_loading) {
                            return const LinearProgressIndicator();
                          } else {
                            return ExpansionPanelList(
                              expansionCallback: (int index, bool isExpanded) {
                                setState(() {
                                  _recipeListItems[index].expanded =
                                      !isExpanded;
                                });
                              },
                              children: _recipeListItems.map((item) {
                                return ExpansionPanel(
                                  headerBuilder:
                                      (BuildContext context, bool isExpanded) {
                                    return ListTile(
                                      title: Text(
                                        item.recipe.recipe,
                                        style: const TextStyle(
                                            fontSize: 30,
                                            height: 3,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  },
                                  body: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 40, 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          // Text(
                                          //   item.recipe.recipe,
                                          //   style: const TextStyle(
                                          //       fontSize: 30,
                                          //       height: 3,
                                          //       fontWeight: FontWeight.bold),
                                          // ),
                                          // const Icon(
                                          //   Icons.done_rounded,
                                          //   color: Colors.green,
                                          //   size: 30,
                                          // ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 10, 40),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Flexible(
                                                  flex: 2,
                                                  fit: FlexFit.loose,
                                                  child: ListView(
                                                    shrinkWrap: true,
                                                    children: [
                                                      for (var i = 0;
                                                          i <
                                                              item
                                                                  .recipe
                                                                  .ingredients
                                                                  .length;
                                                          i++)
                                                        ListTile(
                                                          title: Text(item
                                                              .recipe
                                                              .ingredients[i]),
                                                          trailing: IconButton(
                                                            splashRadius: 20,
                                                            splashColor:
                                                                Colors.green,
                                                            focusColor:
                                                                Colors.green,
                                                            color: Colors.green,
                                                            icon: const Icon(Icons
                                                                .add_circle_outline),
                                                            onPressed: () {},
                                                            highlightColor:
                                                                Colors.green,
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
                                                          i <
                                                              item
                                                                  .recipe
                                                                  .r_direction
                                                                  .length;
                                                          i++)
                                                        ListTile(
                                                          title: Text(item
                                                              .recipe
                                                              .r_direction[i]),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 0, 20, 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Flexible(
                                                  flex: 2,
                                                  fit: FlexFit.loose,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      for (var i = 0;
                                                          i <
                                                              item
                                                                  .recipe
                                                                  .r_nutrition_info
                                                                  .length;
                                                          i++)
                                                        Flexible(
                                                            child: Text(item
                                                                    .recipe
                                                                    .r_nutrition_info[
                                                                i])),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 0, 20, 0),
                                            child: Row(
                                              children: <Widget>[
                                                Flexible(
                                                  flex: 2,
                                                  fit: FlexFit.loose,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Text(
                                                        "Cooking Time ${item.recipe.cooking_time}",
                                                      ),
                                                      Text(
                                                          "Total Time ${item.recipe.total_time}"),
                                                      Text(
                                                          "Recipe Servings ${item.recipe.recipe_servings}"),
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
                                  isExpanded: item.expanded,
                                );
                              }).toList(),
                            );
                          }
                        }),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getRecipes(BuildContext context) async {
    try {
      final recipes = await CCApi().getRecipes(
          Provider.of<AvailableIngredients>(context, listen: false).selected);
      setState(() {
        _loading = false;
        _recipeListItems =
            recipes.map((recipe) => RecipeListItem(recipe: recipe)).toList();
      });
    } catch (e) {
      print(e);
      setState(() {
        _loading = false;
      });
    }
  }
}

class RecipeListItem {
  Recipe recipe;
  bool expanded;

  RecipeListItem({required this.recipe, this.expanded = false});
}
