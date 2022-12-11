import 'package:captain_cook/widgets/Receipes_SelectedIngredients.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../states.dart';


class IngredientSelector extends StatefulWidget {
  IngredientSelector({Key? key}) : super(key: key);

  @override
  State<IngredientSelector> createState() => _IngredientSelectorState();
}

class _IngredientSelectorState extends State<IngredientSelector> {
  
  // void convert(List<String> args) {
  // final data = _fast_csv.parse('selectableIngred.csv');
  // final keys = data.first;
  // final list = data.skip(1).map((e) => Map.fromIterables(keys, e)).toList();
  // print(list.first);
  // print(list[1]['Name']);
  // }

  bool _loadedIngredients = false;

  static List<String> fruitname = ["Apple","Banana","Mango","Orange"];

  final List<SelectableIngredient> _ingredients =  [
    SelectableIngredient("Apple", "apple", icon: const Icon(MdiIcons.tree)),
    SelectableIngredient("Tomato", "apple"),
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
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => Receipes_SelectedIngredients()),);
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
