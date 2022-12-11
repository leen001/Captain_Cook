import 'package:flutter/material.dart';

class Shoppinglist extends StatefulWidget {
  //const shoppinglist({super.key});
  Shoppinglist({required this.name, required this.checked});
  final String name;
  bool checked;
  @override
  State<Shoppinglist> createState() => _ShoppinglistState();
}


class _ShoppinglistState extends State<Shoppinglist> {
  final TextEditingController _textFieldController = TextEditingController();
  final List<Shoppinglist> _shoppinglist = <Shoppinglist>[];
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Todo list'),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        children: _shoppinglist.map((Shoppinglist shoppinglist) {
          return ShoppinglistItem(
            shoppinglist: shoppinglist,
            onShoppinglistChanged: _handleShoppinglistChange,
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _displayDialog(),
          tooltip: 'Add Item',
          child: Icon(Icons.add)),
    );
  }


void _addShoppinglistItem(String name) {
	setState(() {
	  _shoppinglist.add(Shoppinglist(name: name, checked: false));
	});
	_textFieldController.clear();
}

void _handleShoppinglistChange(Shoppinglist shoppinglist) {
	setState(() {
	  shoppinglist.checked = !shoppinglist.checked;
	});
}

Future<void> _displayDialog() async {
	return showDialog<void>(
	  context: context,
	  barrierDismissible: false, // user must tap button!
	  builder: (BuildContext context) {
	    return AlertDialog(
	      title: const Text('Add a new todo item'),
	      content: TextField(
	        controller: _textFieldController,
	        decoration: const InputDecoration(hintText: 'Type your new todo'),
	      ),
	      actions: <Widget>[
	        TextButton(
	          child: const Text('Add'),
	          onPressed: () {
	            Navigator.of(context).pop();
	            _addShoppinglistItem(_textFieldController.text);
	          },
	        ),
	      ],
	    );
	  },
	);
}

    //throw UnimplementedError();
}


class ShoppinglistItem extends StatelessWidget {
  ShoppinglistItem({
    required this.shoppinglist,
    required this.onShoppinglistChanged,
  }) : super(key: ObjectKey(shoppinglist));

  final Shoppinglist shoppinglist;
  final onShoppinglistChanged;

  TextStyle? _getTextStyle(bool checked) {
    if (!checked) return null;

    return TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onShoppinglistChanged(shoppinglist);
      },
      leading: CircleAvatar(
        child: Text(shoppinglist.name[0]),
      ),
      title: Text(shoppinglist.name, style: _getTextStyle(shoppinglist.checked)),
    );
  }
}
