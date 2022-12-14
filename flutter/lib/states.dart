import 'dart:collection';
import 'dart:convert';
import 'api.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AvailableIngredients extends ChangeNotifier {
  final List<Ingredient> _ingredients = [];

  UnmodifiableListView<Ingredient> get all =>
      UnmodifiableListView(_ingredients);

  Iterable<String> get names => _ingredients.map((e) => e.name);

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
    List<String> names = _ingredients.map((e) => e.name).toList();
    return names.contains(ingredient.name);
  }

  void selected(Ingredient ingredient) {
    if (contains(ingredient)) {
      remove(ingredient);
    } else {
      add(ingredient);
    }
  }

  bool get isEmpty => _ingredients.isEmpty;

  void _setFromJson(List<dynamic> json) {
    Iterable<Ingredient> asIngredients =
        json.map((i) => Ingredient.fromJson(i));
    _ingredients.clear();
    for (var i in asIngredients) {
      _ingredients.add(i);
    }
    notifyListeners();
  }

  Future<bool> getFromApi(String baseUrl) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/ingredients'));
      if (response.statusCode == 200) {
        _setFromJson(jsonDecode(response.body));
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
}

class SelectedIng extends ChangeNotifier {
  final List<String> _ingredients = [];

  UnmodifiableListView<String> get all => UnmodifiableListView(_ingredients);

  int get length => _ingredients.length;

  void add(String ingredient) {
    _ingredients.add(ingredient);
    notifyListeners();
  }

  void remove(String ingredient) {
    _ingredients.remove(ingredient);
    notifyListeners();
  }

  void clear() {
    _ingredients.clear();
    notifyListeners();
  }

  void setAll(List<String> ingredients) {
    _ingredients.clear();
    _ingredients.addAll(ingredients);
    notifyListeners();
  }

  bool contains(String ingredient) {
    // List<String> names = _ingredients.map((e) => e.name).toList();
    return _ingredients.contains(ingredient);
  }

  void selected(String ingredient) {
    if (contains(ingredient)) {
      remove(ingredient);
    } else {
      add(ingredient);
    }
  }
}

// class Ingredient {
//   String name;
//   String id;
//   Icon icon;

//   Ingredient(this.name, this.id, {this.icon = const Icon(Icons.restaurant)});
// }

class AuthenticatedUser extends ChangeNotifier {
  late GoogleSignIn _googleSignIn;
  String _error = '';

  Future<GoogleSignInAccount?> get user async {
    if (_googleSignIn.currentUser == null) {
      await _googleSignIn.signInSilently();
    }
    return _googleSignIn.currentUser;
  }

  Future<bool> get isSignedIn {
    return _googleSignIn.isSignedIn();
  }

  bool get hasError => _error.isNotEmpty;
  String get error => _error;

  Future<Map<String, String>>? get authHeaders =>
      _googleSignIn.currentUser?.authHeaders;

  AuthenticatedUser({List<String> scopes = const ['email']}) {
    _googleSignIn = GoogleSignIn(scopes: scopes);
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      notifyListeners();
    });
  }

  Future<void> signIn() async {
    try {
      await _googleSignIn.signIn();
      print(await authHeaders);
      notifyListeners();
    } catch (error) {
      _error = error.toString();
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    notifyListeners();
  }
}
