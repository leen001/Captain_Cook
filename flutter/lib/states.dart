import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
