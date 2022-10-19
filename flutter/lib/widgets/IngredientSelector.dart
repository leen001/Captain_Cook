import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../states.dart';

class IngredientSelector extends StatefulWidget {
  IngredientSelector({Key? key}) : super(key: key);

  @override
  State<IngredientSelector> createState() => _IngredientSelectorState();
}

class _IngredientSelectorState extends State<IngredientSelector> {
  bool _loadedIngredients = false;
  final List<SelectableIngredient> _ingredients = [
    SelectableIngredient("Apple", "apple", icon: const Icon(Icons.apple)),
  ];
  List<Ingredient> _selectedIngredients() {
    return _ingredients
        .where((ingredient) => ingredient.selected)
        .toList()
        .map((e) => e.toIngredient())
        .toList();
  }

  void _saveSelection(context) {
    Provider.of<AvailableIngredients>(context, listen: false)
        .setAll(_selectedIngredients());
    Navigator.pop(context);
  }

  List<Widget> _ingredientsFactory(AvailableIngredients availableIngredients) {
    if (!_loadedIngredients) {
      for (var i in _ingredients) {
        i.selected = availableIngredients.contains(i.toIngredient());
      }
      _loadedIngredients = true;
    }
    return _ingredients.map((ingredient) {
      return Card(
        child: ListTile(
          leading: ingredient.icon,
          title: Text(ingredient.name),
          trailing: Container(
            width: 50,
            child: Checkbox(
              value: ingredient.selected,
              onChanged: (bool? value) {
                setState(() {
                  ingredient.selected = value!;
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
                  onPressed: () => _saveSelection(context),
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

class SelectableIngredient extends Ingredient {
  bool selected = false;

  SelectableIngredient(String name, String id,
      {Icon icon = const Icon(Icons.restaurant)})
      : super(name, id, icon: icon);

  Ingredient toIngredient() {
    return Ingredient(name, id, icon: icon);
  }
}
