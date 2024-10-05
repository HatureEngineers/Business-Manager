// import 'package:flutter/material.dart';
// import 'firebase_services.dart';  // Firebase related methods
// import 'widgets.dart';           // UI widgets like buildOldPartySection, buildNewPartySection
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class AddPurchasePage extends StatefulWidget {
//   @override
//   _AddPurchasePageState createState() => _AddPurchasePageState();
// }
//
// class _AddPurchasePageState extends State<AddPurchasePage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _transactionController = TextEditingController();
//   final TextEditingController _additionalAmountController = TextEditingController();
//   final TextEditingController _searchController = TextEditingController(); // Search controller
//   DateTime _selectedDate = DateTime.now();
//   File? _selectedImage;
//   String _partyType = 'পুরাতন পার্টি';
//   String? _selectedSupplier;
//   String _supplierName = ''; // Supplier name for display
//   String _supplierPhone = ''; // Supplier phone for display
//   double _previousAmount = 0.0;
//
//   // Image picker method for picking an image
//   Future<void> _pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     }
//   }
//
//   // Get suppliers stream method (moved to this class)
//   Stream<QuerySnapshot> _getSuppliers() {
//     String? uid = getCurrentUserId();
//     if (uid != null) {
//       return FirebaseFirestore.instance.collection('users').doc(uid).collection('suppliers').snapshots();
//     }
//     return const Stream.empty();
//   }
//
//   // Save additional amount for old party (moved to this class)
//   void _saveAdditionalAmount() async {
//     if (_additionalAmountController.text.isNotEmpty) {
//       String? uid = getCurrentUserId();
//       if (uid != null && _selectedSupplier != null) {
//         double additionalAmount = double.parse(_additionalAmountController.text);
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(uid)
//             .collection('suppliers')
//             .doc(_selectedSupplier)
//             .update({
//           'transaction': _previousAmount + additionalAmount,
//           'transactionDate': DateTime.now().toIso8601String(),
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('পরিমাণ সফলভাবে যুক্ত হয়েছে')),
//         );
//
//         _additionalAmountController.clear();
//         // Reload the previous amount after update
//         _previousAmount += additionalAmount;
//       }
//     }
//   }
//
//   // When a supplier is selected, update the details for display
//   void _onSupplierSelected(String supplierId) async {
//     String? uid = getCurrentUserId();
//     if (uid != null) {
//       DocumentSnapshot supplierSnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(uid)
//           .collection('suppliers')
//           .doc(supplierId)
//           .get();
//
//       setState(() {
//         _selectedSupplier = supplierId;
//         _supplierName = supplierSnapshot['name'];
//         _supplierPhone = supplierSnapshot['phone'];
//         _previousAmount = supplierSnapshot['transaction'];
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('ক্রয়', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.green,
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildPartyTypeSelection(),
//                 SizedBox(height: 20),
//                 _partyType == 'নতুন পার ্টি'
//                     ? buildNewPartySection(
//                   nameController: _nameController,
//                   phoneController: _phoneController,
//                   transactionController: _transactionController,
//                   onPickImage: _pickImage,
//                   selectedImage: _selectedImage,
//                   onSaveNewSupplier: () {
//                     saveNewSupplier(
//                       name: _nameController.text,
//                       phone: _phoneController.text,
//                       transaction: double.parse(_transactionController.text),
//                       transactionDate: _selectedDate,
//                       imageFile: _selectedImage,
//                     );
//                   },
//                 )
//                     : buildOldPartySection(
//                   searchController: _searchController,
//                   suppliersStream: _getSuppliers(),
//                   onSupplierSelected: _onSupplierSelected,
//                   supplierName: _supplierName,
//                   supplierPhone: _supplierPhone,
//                   previousAmount: _previousAmount,
//                   additionalAmountController: _additionalAmountController,
//                   onSaveAdditionalAmount: _saveAdditionalAmount,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Build party type selection widget
//   Widget _buildPartyTypeSelection() {
//     return Row(
//       children: [
//         Expanded(
//           child: ListTile(
//             title: Text('নতুন পার্টি'),
//             leading: Radio(
//               value: 'নতুন পার্টি',
//               groupValue: _partyType,
//               onChanged: (value) {
//                 setState(() {
//                   _partyType = value as String;
//                 });
//               },
//             ),
//           ),
//         ),
//         Expanded(
//           child: ListTile(
//             title: Text('পুরাতন পার্টি'),
//             leading: Radio(
//               value: 'পুরাতন পার্টি',
//               groupValue: _partyType,
//               onChanged: (value) {
//                 setState(() {
//                   _partyType = value as String;
//                 });
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }