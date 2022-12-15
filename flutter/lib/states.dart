import 'dart:collection';
import 'dart:convert';
import 'api.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AvailableIngredients extends ChangeNotifier {
  final List<Ingredient> _ingredients = [];
  final List<String> _selected = [];

  UnmodifiableListView<Ingredient> get all =>
      UnmodifiableListView(_ingredients);

  UnmodifiableListView<String> get selected => UnmodifiableListView(_selected);

  Iterable<String> get names => _ingredients.map((e) => e.name);

  int get length => _ingredients.length;
  bool get isEmpty => _ingredients.isEmpty;

  int get selectedLength => _selected.length;
  bool get noneSelected => _selected.isEmpty;

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

  void select(String ingredient) {
    if (_ingredients.map((i) => i.name).contains(ingredient) &&
        !_selected.contains(ingredient)) {
      _selected.add(ingredient);
      notifyListeners();
    }
  }

  void deselect(String ingredient) {
    if (_selected.contains(ingredient)) {
      _selected.remove(ingredient);
      notifyListeners();
    }
  }

  void loadFromApi(Future<List<Ingredient>> Function() apiCall) async {
    _ingredients.clear();
    _ingredients.addAll(await apiCall());
    if (_ingredients.isNotEmpty) {
      notifyListeners();
    }
  }
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
  String get error {
    String error = _error;
    _error = '';
    return error;
  }

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

  void signOut() {
    _googleSignIn.disconnect().then((_) => notifyListeners());
  }
}
