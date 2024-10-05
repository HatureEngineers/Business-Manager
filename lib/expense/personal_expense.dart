import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Expense {
  final String name;
  final double price;
  final String category;

  Expense({required this.name, required this.price, required this.category});

  // Convert a Expense into a Map.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
    };
  }

  // Convert a Map into a Expense.
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      name: map['name'],
      price: map['price'],
      category: map['category'],
    );
  }
}

class PersonalExpensePage extends StatefulWidget {
  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<PersonalExpensePage> {
  final _formKey = GlobalKey<FormState>();
  String _expenseName = '';
  double _expensePrice = 0.0;
  String _selectedCategory = 'Uncategorized';
  List<Expense> _expense = [];
  List<Expense> _filteredExpense = [];
  String _searchQuery = '';

  // List to store categories
  List<String> _categories = ['Uncategorized'];

  @override
  void initState() {
    super.initState();
    _loadExpense(); // Load Expense from SharedPreferences
    _loadCategories(); // Load categories from SharedPreferences
  }

  // Function to load Expense from SharedPreferences
  void _loadExpense() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? expenseJson = prefs.getString('expense');
    if (expenseJson != null) {
      List<dynamic> expenseList = json.decode(expenseJson);
      setState(() {
        _expense = expenseList.map((data) => Expense.fromMap(data)).toList();
        _filteredExpense = _expense; // Initialize filtered list
      });
    }
  }

  // Function to save Expense to SharedPreferences
  void _saveExpense() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String expenseJson =
    json.encode(_expense.map((expense) => expense.toMap()).toList());
    await prefs.setString('expense', expenseJson);
  }

  // Function to load categories from SharedPreferences
  void _loadCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? categoriesJson = prefs.getString('categories');
    if (categoriesJson != null) {
      List<dynamic> categoryList = json.decode(categoriesJson);
      setState(() {
        _categories = categoryList.cast<String>(); // Load categories
      });
    }
  }

  // Function to save categories to SharedPreferences
  void _saveCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String categoriesJson = json.encode(_categories);
    await prefs.setString('categories', categoriesJson);
  }

  // Function to add a Expense
  void _addExpense() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _expense.add(Expense(
          name: _expenseName,
          price: _expensePrice,
          category: _selectedCategory,
        ));
        _filteredExpense = _expense; // Reset filtered list
        _saveExpense(); // Save Expense list to SharedPreferences
      });

      _formKey.currentState!.reset(); // Clear form fields
    }
  }

  // Function to remove a Expense
  void _removeExpense(int index) {
    setState(() {
      _expense.removeAt(index);
      _filteredExpense = _expense; // Update filtered list
      _saveExpense(); // Save updated Expense list
    });
  }

  // Function to search Expense
  void _searchExpense(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredExpense = _expense
          .where((expense) =>
      expense.name.toLowerCase().contains(_searchQuery) ||
          expense.category.toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  // Function to add a new category through a dialog
  void _showAddCategoryDialog() {
    String newCategory = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('খরচের খাত/তালিকা লিখুনঃ'),
          content: TextField(
            onChanged: (value) {
              newCategory = value;
            },
            decoration: InputDecoration(hintText: "এখানে লিখুন"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newCategory.isNotEmpty &&
                    !_categories.contains(newCategory)) {
                  setState(() {
                    _categories.add(newCategory);
                    _saveCategories(); // Save categories to SharedPreferences
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('যুক্ত'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('বাতিল'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('খরচের হিসাব'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                labelText: 'Search Expense',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => _searchExpense(value),
            ),
            SizedBox(height: 20),

            // Expense form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'খরচের বর্ণনা লিখুন'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'দয়া করে খরচের কারণটি লিখুন';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _expenseName = value!;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'খরচের পরিমাণ(টাকা)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || double.tryParse(value) == null) {
                        return 'দয়া করে খরচের পরিমাণ লিখুন';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _expensePrice = double.parse(value!);
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                    items: _categories
                        .map<DropdownMenuItem<String>>((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'খরচের তালিকা নির্বাচন করুন'),
                  ),
                  SizedBox(height: 20),

                  // Add Expense button
                  ElevatedButton(
                    onPressed: _addExpense,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue, // Change this to your desired text color
                    ),
                    child: Text('খরচ যুক্ত করুন'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Add new category button
            ElevatedButton(
              onPressed: _showAddCategoryDialog,

              child: Text('নতুন খরচের তালিকা যুক্ত করুন'),
            ),
            SizedBox(height: 20),

            // Expense list
            Expanded(
              child: _filteredExpense.isEmpty
                  ? Center(child: Text('কোনো খরচ যুক্ত করা নাই'))
                  : ListView.builder(
                itemCount: _filteredExpense.length,
                itemBuilder: (context, index) {
                  final expense = _filteredExpense[index];
                  return ListTile(
                    title: Text(expense.name),
                    subtitle: Text(
                        'Price: ৳${expense.price.toStringAsFixed(2)} | Category: ${expense.category}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _removeExpense(index);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
