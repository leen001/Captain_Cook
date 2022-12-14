//import 'package:captain_cook/widgets/Receipes_SelectedIngredients.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:captain_cook/widgets/Recipe_Output.dart';

import 'package:captain_cook/states.dart';
import 'package:captain_cook/api.dart';

class IngredientSelector extends StatefulWidget {
  IngredientSelector({Key? key}) : super(key: key);

  @override
  State<IngredientSelector> createState() => _IngredientSelectorState();
}

class _IngredientSelectorState extends State<IngredientSelector> {
  bool _loadedIngredients = false;

  final List<Ingredient> _ingredients = [];
  // List<dynamic> _selectedIngredients() {
  //   return _ingredients.add()
  //       .where((ingredient) => ingredient.selected)
  //       .map((ingredient) => ingredient.toIngredient())
  //       .toList();
  // }

  // void _saveSelection(context) {
  //   Provider.of<AvailableIngredients>(context, listen: false).setAll(ingredients);
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => RecipeList()),
  //   );
  // }

  List<Widget> _ingredientsFactory(AvailableIngredients availableIngredients) {
    bool selected = false;
    if (!_loadedIngredients) {
      for (Ingredient i in _ingredients) {
        availableIngredients.selected(i);
        selected = true;
      }
      _loadedIngredients = true;
    }
    return _ingredients.map((ingredient) {
      return Card(
        child: ListTile(
          leading: Icon(MdiIcons.foodApple),
          title: Text(ingredient.name),
          trailing: Container(
            width: 50,
            child: Checkbox(
              value: false,
              onChanged: (bool? value) {
                setState(() {
                  selected = value!;
                });
              },
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AvailableIngredients>(
      builder: (context, availableIngredients, child) => Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          Hero(
            tag: "ingredient_selector_open",
            child: AppBar(
              title: const Text("Select your ingredients"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () => _ingredientsFactory(availableIngredients),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: _ingredientsFactory(availableIngredients),
            ),
          ),
        ]),
      ),
    );
  }
}




// class SelectableIngredient extends Ingredient {
//   bool selected = false;

//   SelectableIngredient(String name, String id, {Icon icon = const Icon(Icons.restaurant)})
//       : super(name, id, icon: icon);

//   Ingredient toIngredient() {
//     return Ingredient(name, id, icon: icon, id: '', name: '');
//   }
// }
