import 'package:captain_cook/states.dart';
import 'package:flutter/material.dart';
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

const API_BASE_URL = String.fromEnvironment('API_BASE_URL',
    defaultValue: 'http://localhost:3000');

class Receipes_SelectedIngredients extends StatefulWidget {
  const Receipes_SelectedIngredients({super.key});
  @override
  State<Receipes_SelectedIngredients> createState() =>
      _Receipes_SelectedIngredientsState();
}

class _Receipes_SelectedIngredientsState
    extends State<Receipes_SelectedIngredients> {
  Future<List<Recipe>> _getRecipes() async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/recipes'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'count': 5,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.close),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: SingleChildScrollView(
              primary: true,
              child: Column(
                children: [
                  FutureBuilder<List<Recipe>>(
                    future: _getRecipes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: _buildRecipeWidgets(snapshot.data!),
                        );
                        //
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      return const LinearProgressIndicator();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
