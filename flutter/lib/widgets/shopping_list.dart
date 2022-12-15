import 'package:captain_cook/api.dart';
import 'package:captain_cook/states.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Shoppinglist extends StatefulWidget {
  const Shoppinglist({super.key});

  @override
  State<Shoppinglist> createState() => _ShoppinglistState();
}

class _ShoppinglistState extends State<Shoppinglist> {
  final TextEditingController _textFieldController = TextEditingController();
  List<Ingredient> _list = <Ingredient>[];
  bool _makingCall = false;

  void _removeItem(int id) {
    setState(() {
      _makingCall = true;
      _list.removeWhere((Ingredient item) => item.id == id);
    });
    CCApi()
        .removeIngredientFromShoppingList(id,
            Provider.of<AuthenticatedUser>(context, listen: false).authHeaders)
        .then((newList) => setState(() {
              _list = newList;
              _makingCall = false;
            }));
  }

  void _addFromInput(String input) {
    if (input.isEmpty) return;
    setState(() {
      _makingCall = true;
      _list.add(Ingredient(name: input));
    });
    CCApi()
        .addIngredientToShoppingList(input,
            Provider.of<AuthenticatedUser>(context, listen: false).authHeaders)
        .then((newList) => setState(() {
              _list = newList;
              _makingCall = false;
            }));
  }

  Future<void> _displayDialog() async {
    void submit() {
      Navigator.of(context).pop();
      _addFromInput(_textFieldController.text);
      _textFieldController.clear();
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new todo item'),
          content: TextField(
            autofocus: true,
            autocorrect: true,
            onSubmitted: (String value) => submit(),
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Type your new todo'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: submit,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _makingCall = true;
    CCApi()
        .getShoppingList(
            Provider.of<AuthenticatedUser>(context, listen: false).authHeaders)
        .then((list) => setState(() {
              _list = list;
              _makingCall = false;
            }));
  }

  @override
  Widget build(BuildContext context) {
    Widget loader = const Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(
        leading: (_makingCall) ? const RefreshProgressIndicator() : null,
        title: const Text('Shopping List'),
      ),
      body: Consumer<AuthenticatedUser>(
        builder: (context, googleAuth, child) => FutureBuilder(
            future: googleAuth.isSignedIn,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return loader;
              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: <Widget>[
                  for (final ingredient in _list)
                    ShoppinglistItem(
                      id: ingredient.id ?? 0,
                      name: ingredient.name,
                      remove: () => _removeItem(ingredient.id!),
                      disabled: _makingCall,
                    ),
                ],
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _displayDialog(),
          tooltip: 'Add Item',
          child: const Icon(Icons.add)),
    );
  }
}

class ShoppinglistItem extends StatelessWidget {
  ShoppinglistItem({
    required this.name,
    required this.remove,
    this.id = 0,
    this.disabled = false,
  }) : super(key: ObjectKey(name));

  final String name;
  final VoidCallback remove;
  final int id;
  final bool disabled;

  final TextStyle _style = const TextStyle(
    color: Colors.black54,
    // decoration: TextDecoration.lineThrough,
  );

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ObjectKey(name + id.toString()),
      onDismissed: (direction) => remove(),
      direction:
          (disabled) ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(color: Colors.red),
      child: ListTile(
          enabled: !disabled,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(name[0].toUpperCase()),
          ),
          title: Text(name, style: _style),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: (disabled) ? null : remove,
          )),
    );
  }
}
