import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopinglist/data/Categories.dart';
import 'package:shopinglist/models/grocery_item.dart';
import 'package:shopinglist/widgets/new_item.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loaditems();
  }

  void _loaditems() async {
    final url = Uri.https(
        'flutter-prep-f6ddc-default-rtdb.firebaseio.com', 'shopping-list.json');

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = "Failed to get data!, Please try again later";
        });
      }
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listdata = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in listdata.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;

        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            date: item.value['date'],
            category: category,
          ),
        );
      }
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (err) {
      setState(() {
        _error = "Something went wrong!,Please try again";
      });
    }
  }

  void _addItems() async {
    final newItems = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItems(),
      ),
    );
    if (newItems == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItems);
    });
  }

  void _removeItem(GroceryItem item) async {
    final _index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https('flutter-prep-f6ddc-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      print(response.statusCode);
      setState(() {
        _groceryItems.insert(_index, item);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something worng item can't delete"),
            duration: Duration(milliseconds: 1000),
          ),
        );
      });
    }

    // ScaffoldMessenger.of(context).clearSnackBars();
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     duration: const Duration(seconds: 3),
    //     content: const Text("Grocery Deleted"),
    //     action: SnackBarAction(
    //       label: "Undo",
    //       onPressed: () {
    //         setState(() {
    //           _groceryItems.insert(_index, item);
    //         });
    //       },
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    Widget Content = const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "No items.....",
          ),
          Text(
            "Please Add new Items....",
          ),
        ],
      ),
    );

    if (_isLoading) {
      Content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      Content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) {
          return Dismissible(
            background: Container(
              color: Theme.of(context).colorScheme.error.withOpacity(0.90),
            ),
            key: ValueKey(_groceryItems[index].id),
            onDismissed: (direction) {
              _removeItem(_groceryItems[index]);
            },
            child: Card(
              margin: const EdgeInsets.only(top: 10, right: 8, left: 8),
              child: ListTile(
                leading: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    color: _groceryItems[index].category.color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                title: Text(
                  _groceryItems[index].name,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 20,
                      ),
                ),
                subtitle: Text(
                  _groceryItems[index].category.title,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Qty: ${_groceryItems[index].quantity.toString()}',
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        _groceryItems[index].date,
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    if (_error != null) {
      Content = Center(
        child: Text(_error!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Content,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItems,
        elevation: 10,
        splashColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: const Icon(Icons.add),
      ),
    );
  }
}
