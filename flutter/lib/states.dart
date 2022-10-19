import 'dart:collection';

import 'package:flutter/material.dart';

class AvailableIngredients extends ChangeNotifier {
  final List<Ingredient> _ingredients = [];

  UnmodifiableListView<Ingredient> get all =>
      UnmodifiableListView(_ingredients);

  int get length => _ingredients.length;

  void add(Ingredient ingredient) {
    _ingredients.add(ingredient);
    notifyListeners();
  }

  void remove(Ingredient ingredient) {
    _ingredients.remove(ingredient);
    notifyListeners();
  }

  void clear() {
    _ingredients.clear();
    notifyListeners();
  }

  void setAll(List<Ingredient> ingredients) {
    _ingredients.clear();
    _ingredients.addAll(ingredients);
    notifyListeners();
  }

  bool contains(Ingredient ingredient) {
    List<String> ids = _ingredients.map((e) => e.id).toList();
    return ids.contains(ingredient.id);
  }
}

class Ingredient {
  String name;
  String id;
  Icon icon;

  Ingredient(this.name, this.id, {this.icon = const Icon(Icons.restaurant)});
}
