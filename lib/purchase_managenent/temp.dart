import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPurchasePage extends StatefulWidget {
  @override
  _AddPurchasePageState createState() => _AddPurchasePageState();
}

class _AddPurchasePageState extends State<AddPurchasePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _transactionController = TextEditingController();
  final TextEditingController _additionalAmountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  String? _image;
  String _partyType = 'পুরাতন পার্টি'; // Set default value to 'পুরাতন পার্টি'
  String? _selectedSupplier;
  double _previousAmount = 0.0; // Placeholder for previous amount

  // Get current user's UID
  String? getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  // Image picker function
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Fetch suppliers list for পুরাতন পার্টি
  Stream<QuerySnapshot> _getSuppliers() {
    String? uid = getCurrentUserId();
    if (uid != null) {
      return FirebaseFirestore.instance.collection('users').doc(uid).collection('suppliers').snapshots();
    }
    return const Stream.empty();
  }

  // Save supplier function for নতুন পার্টি
  void _saveNewSupplier() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('supplier_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(_selectedImage!);
        _image = await storageRef.getDownloadURL();
      } else {
        _image = 'assets/error.jpg'; // Default image path if no image is picked
      }

      String? uid = getCurrentUserId();
      if (uid != null) {
        final supplierData = {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'image': _image,
          'transaction': double.parse(_transactionController.text),
          'transactionDate': _selectedDate.toIso8601String(),
          'userId': uid,
        };

        await FirebaseFirestore.instance.collection('users').doc(uid).collection('suppliers').add(supplierData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('সাপ্লায়ার সফলভাবে যুক্ত হয়েছে')),
        );

        _formKey.currentState!.reset();
        setState(() {
          _selectedDate = DateTime.now();
          _selectedImage = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ব্যবহারকারী লগ ইন করা নেই')),
        );
      }
    }
  }

  // Save additional amount for পুরাতন পার্টি
  void _saveAdditionalAmount() async {
    if (_additionalAmountController.text.isNotEmpty) {
      String? uid = getCurrentUserId();
      if (uid != null && _selectedSupplier != null) {
        double additionalAmount = double.parse(_additionalAmountController.text);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('suppliers')
            .doc(_selectedSupplier)
            .update({
          'transaction': _previousAmount + additionalAmount,
          'transactionDate': DateTime.now().toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('পরিমাণ সফলভাবে যুক্ত হয়েছে')),
        );

        _additionalAmountController.clear();
      }
    }
  }

  Widget _buildOldPartySection() {
    final TextEditingController _searchController = TextEditingController();
    String? _selectedSupplierName;
    String? _selectedSupplierPhone;
    double _previousAmount = 0.0; // Initialize _previousAmount to avoid potential errors

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TypeAheadField(
          onSelected: (dynamic suggestion) {
            setState(() {
              _selectedSupplier = suggestion['id'];
              _selectedSupplierName = suggestion['name'];
              _selectedSupplierPhone = suggestion['phone'];
              _previousAmount = suggestion['transaction'] ?? 0.0; // Handle potential missing 'transaction' field
            });
          },
          // textFieldBuilder: (context, TextEditingController controller, FocusNode focusNode) {
          //   return TextField(
          //     controller: controller,
          //     focusNode: focusNode,
          //     decoration: InputDecoration(
          //       labelText: 'সাপ্লায়ার খুঁজুন',
          //       border: OutlineInputBorder(),
          //     ),
          //   );
          // },
          suggestionsCallback: (pattern) async {
            String? uid = getCurrentUserId();
            if (uid != null) {
              QuerySnapshot snapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('suppliers')
                  .where('name', isGreaterThanOrEqualTo: pattern)
                  .where('name', isLessThanOrEqualTo: pattern + '\uf8ff')
                  .get();
              return snapshot.docs.map((e) => e.data()).toList();
            }
            return [];
          },
          itemBuilder: (context, dynamic supplier) {
            return ListTile(
              title: Text(supplier['name']),
              subtitle: Text(supplier['phone']),
            );
          },
          emptyBuilder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('কোনও সাপ্লায়ার খুঁজে পাওয়া যায়নি'),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'নাম: $_selectedSupplierName',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          'ফোন নম্বর: $_selectedSupplierPhone',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 10),
        Text(
          'আগের লেনদেন: $_previousAmount টাকা',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        TextFormField(
          controller: _additionalAmountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'ক্রয়ের পরিমান লিখুন(টাকা)',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'ক্রয়ের পরিমান লিখুন';
            }
            return null;
          },
        ),
      ],
    );
  }

  // UI for নতুন পার্টি
  Widget _buildNewPartySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              image: _selectedImage == null
                  ? DecorationImage(
                image: AssetImage('assets/error.jpg'),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: _selectedImage == null
                ? Center(child: Text('ছবি নির্বাচন করুন', style: TextStyle(color: Colors.black)))
                : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: double.infinity,
                height: 150,
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'নাম',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'এখানে নাম লিখুন';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'ফোন নম্বর',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'এখানে ফোন নম্বর লিখুন';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
        TextFormField(
          controller: _transactionController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'লেনদেনের পরিমাণ(টাকা)',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'এখানে লেনদেনের পরিমাণ লিখুন';
            }
            if (double.tryParse(value) == null) {
              return 'সঠিক পরিমাণ লিখুন';
            }
            return null;
          },
        ),
        SizedBox(height: 30),
        Center(
          child: ElevatedButton(
            onPressed: _saveNewSupplier,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              backgroundColor: Colors.green,
            ),
            child: Text(
              'সেভ করুন',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // UI for party type selection
  Widget _buildPartyTypeSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              _partyType = 'পুরাতন পার্টি';
            });
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            backgroundColor: _partyType == 'পুরাতন পার্টি' ? Colors.green : Colors.grey,
          ),
          child: Text(
            'পুরাতন পার্টি',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _partyType = 'নতুন পার্টি';
            });
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            backgroundColor: _partyType == 'নতুন পার্টি' ? Colors.green : Colors.grey,
          ),
          child: Text(
            'নতুন পার্টি',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ক্রয়', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPartyTypeSelection(), // Replacing dropdown with buttons
                SizedBox(height: 20),
                _partyType == 'নতুন পার্টি' ? _buildNewPartySection() : _buildOldPartySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}