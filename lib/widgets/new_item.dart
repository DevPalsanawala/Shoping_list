import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopinglist/data/Categories.dart';
import 'package:shopinglist/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:shopinglist/models/grocery_item.dart';

class NewItems extends StatefulWidget {
  const NewItems({super.key});

  @override
  State<NewItems> createState() => _NewItemsState();
}

class _NewItemsState extends State<NewItems> {
  final _formkey = GlobalKey<FormState>();
  var _enterName = '';
  var _enterQuantity = 1;
  var _selectedcategory = categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveItem() async {
    if (_formkey.currentState!.validate()) {
      // tregered Validator of form
      _formkey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('d MMM yyyy').format(now);
      // save form data
      final url = Uri.https('flutter-prep-f6ddc-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': _enterName,
            'quantity': _enterQuantity,
            'category': _selectedcategory.title,
            'date': formattedDate,
          },
        ),
      );
      print(response.body);
      print(response.statusCode);

      final Map<String, dynamic> resData = json.decode(response.body);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(
        GroceryItem(
          id: resData['name'],
          name: _enterName,
          quantity: _enterQuantity,
          date: formattedDate,
          category: _selectedcategory,
        ),
      );
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Items"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                textAlignVertical: TextAlignVertical.center,
                maxLength: 50,
                decoration: InputDecoration(
                  label: const Text(
                    "Name",
                    style: TextStyle(fontSize: 20),
                  ),
                  prefixIcon: Icon(
                    Icons.category,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 || // trim remove whitespace
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enterName = value!;
                },
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      maxLength: 5,
                      initialValue: _enterQuantity.toString(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        label: const Text(
                          "Quantity",
                          style: TextStyle(fontSize: 20),
                        ),
                        prefixIcon: Icon(
                          Icons.production_quantity_limits_outlined,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) == null ||
                                int.tryParse(value)! <= 0
                            // tryparse treats String as int and check condition
                            // print(int.tryParse('2021')); // 2021
                            //print(int.tryParse('1f')); // null
                            ) {
                          return 'Must be a valid number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enterQuantity = int.parse(value!);
                        //convert to int
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedcategory,
                      items: [
                        for (final category in categories.entries)
                          // for loop can't itrate the Map.
                          // so Flutter Provides "entries" for itrate the Map.
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      color: category.value.color,
                                      borderRadius: BorderRadius.circular(5)),
                                ),
                                const SizedBox(width: 10),
                                Text(category.value.title)
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedcategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSending
                          ? null
                          : () {
                              _formkey.currentState!.reset();
                              //reset the form
                            },
                      child: const Text(
                        "Reset",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSending ? null : _saveItem,
                      child: _isSending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(),
                            )
                          : const Text(
                              "Add Item",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
