import 'package:captain_cook/states.dart';
import 'package:flutter/material.dart';
import 'package:captain_cook/api.dart';
import 'package:provider/provider.dart';
import 'package:rate/rate.dart';

import 'selected_ingredients.dart';

class RecipeList extends StatefulWidget {
  const RecipeList({Key? key, this.title = 'Recipe List'}) : super(key: key);
  final String title;

  @override
  _RecipeListState createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  List<RecipeListItem> _recipeListItems = <RecipeListItem>[];
  bool _loading = false;
  bool _addingToShoppingList = false;

  @override
  void initState() {
    super.initState();
    _loading = true;
    _getRecipes(context).then((_) {
      setState(() {
        _recipeListItems[0].expanded = true;
      });
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
                            // dismissable: true,
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
                                      title: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.recipe.recipe,
                                                style: const TextStyle(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Chip(
                                              label: Text(((item.recipe
                                                              .rating_score !=
                                                          -1)
                                                      ? item.recipe.rating_score
                                                      : 0)
                                                  .toString()),
                                              avatar: const Icon(Icons.star),
                                              backgroundColor: Colors.yellow,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Chip(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .primaryColor,
                                                label: Text(
                                                  '${item.recipe.score}%',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                )),
                                          ],
                                        ),
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
                                                            disabledColor: Colors
                                                                .black54
                                                                .withOpacity(
                                                                    0.5),
                                                            icon: const Icon(Icons
                                                                .add_circle_outline),
                                                            onPressed:
                                                                (_addingToShoppingList)
                                                                    ? null
                                                                    : () {
                                                                        setState(
                                                                            () {
                                                                          _addingToShoppingList =
                                                                              true;
                                                                        });
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(SnackBar(
                                                                          content:
                                                                              Row(
                                                                            children: const [
                                                                              SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
                                                                              SizedBox(width: 20),
                                                                              Text('Adding to your shopping list...'),
                                                                            ],
                                                                          ),
                                                                          dismissDirection:
                                                                              DismissDirection.none,
                                                                          duration:
                                                                              const Duration(days: 1),
                                                                        ));
                                                                        CCApi()
                                                                            .addIngredientToShoppingList(item.recipe.ingredients[i],
                                                                                Provider.of<AuthenticatedUser>(context, listen: false).authHeaders)
                                                                            .then((_) {
                                                                          ScaffoldMessenger.of(context)
                                                                              .hideCurrentSnackBar();
                                                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                                              backgroundColor: Colors.green,
                                                                              content: Text('Added to shopping list')));
                                                                          setState(
                                                                              () {
                                                                            _addingToShoppingList =
                                                                                false;
                                                                          });
                                                                        });
                                                                      },
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
                                          RecipeRating(
                                            recipe: item.recipe,
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

class RecipeRating extends StatefulWidget {
  const RecipeRating({Key? key, required this.recipe}) : super(key: key);
  final Recipe recipe;

  @override
  State<RecipeRating> createState() => _RecipeRatingState();
}

class _RecipeRatingState extends State<RecipeRating> {
  Recipe? recipe;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    recipe = widget.recipe;
  }

  void _addRating(context, int rating) {
    print('rating: $rating');
    CCApi()
        .addRatingToRecipe(recipe!.id, rating,
            Provider.of<AuthenticatedUser>(context, listen: false).authHeaders)
        .then((newRecipe) {
      setState(() {
        _locked = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Rate(
      iconSize: 30,
      allowHalf: false,
      allowClear: false,
      // initialValue: ((recipe!.rating_score != -1) ? recipe!.rating_score : 0)!
      //     .floorToDouble(),
      onChange:
          (!_locked) ? (value) => _addRating(context, value.toInt()) : null,
      readOnly: _locked,
    );
  }
}
