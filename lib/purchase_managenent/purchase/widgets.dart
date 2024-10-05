// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase imports
// import 'dart:io';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
//
// // Widget for building Old Party section with search functionality
// Widget buildOldPartySection({
//   required TextEditingController searchController,
//   required Stream<QuerySnapshot<Object?>> suppliersStream,
//   required void Function(String) onSupplierSelected,
//   required double previousAmount,
//   required String supplierName,
//   required String supplierPhone,
//   required TextEditingController additionalAmountController,
//   required VoidCallback onSaveAdditionalAmount,
// }) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       // Search bar for suppliers using TypeAheadField
//       TypeAheadField(
//         onSelected: (dynamic suggestion) {
//           onSupplierSelected(suggestion['id']); // Select supplier by ID
//         },
//         textFieldConfiguration: (context, controller, focusNode) {
//           return TextField(
//             controller: controller,
//             focusNode: focusNode,
//             decoration: InputDecoration(
//               labelText: 'সাপ্লায়ার খুঁজুন',
//               border: OutlineInputBorder(),
//             ),
//           );
//         },
//         suggestionsCallback: (pattern) async {
//           QuerySnapshot snapshot = await FirebaseFirestore.instance
//               .collection('suppliers')
//               .where('name', isGreaterThanOrEqualTo: pattern)
//               .where('name', isLessThanOrEqualTo: pattern + '\uf8ff')
//               .get();
//           return snapshot.docs.map((e) => e.data()).toList();
//         },
//         itemBuilder: (context, dynamic supplier) {
//           return ListTile(
//             title: Text(supplier['name']),
//             subtitle: Text(supplier['phone']),
//           );
//         },
//         emptyBuilder: (context) => Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text('কোনও সাপ্লায়ার খুঁজে পাওয়া যায়নি'),
//         ),
//       ),
//       SizedBox(height: 20),
//
//       // Display selected supplier info
//       Text(
//         'নাম: $supplierName',
//         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//       Text(
//         'ফোন নম্বর: $supplierPhone',
//         style: TextStyle(fontSize: 16),
//       ),
//       SizedBox(height: 10),
//       Text(
//         'বর্তমান লেনদেন: $previousAmount টাকা',
//         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//       SizedBox(height: 20),
//
//       // Input field for adding transaction
//       TextFormField(
//         controller: additionalAmountController,
//         keyboardType: TextInputType.number,
//         decoration: InputDecoration(
//           labelText: 'ক্রয়ের পরিমান লিখুন(টাকা)',
//           border: OutlineInputBorder(),
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'এখানে পরিমাণ লিখুন';
//           }
//           return null;
//         },
//       ),
//       SizedBox(height: 20),
//
//       // Save button
//       Center(
//         child: ElevatedButton(
//           onPressed: onSaveAdditionalAmount,
//           style: ElevatedButton.styleFrom(
//             padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
//             backgroundColor: Colors.green,
//           ),
//           child: Text(
//             'সেভ করুন',
//             style: TextStyle(fontSize: 18, color: Colors.white),
//           ),
//         ),
//       ),
//     ],
//   );
// }
//
// // Widget for building New Party section
// Widget buildNewPartySection({
//   required TextEditingController nameController,
//   required TextEditingController phoneController,
//   required TextEditingController transactionController,
//   required VoidCallback onPickImage,
//   required File? selectedImage,
//   required VoidCallback onSaveNewSupplier,
// }) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       GestureDetector(
//         onTap: onPickImage,
//         child: Container(
//           height: 150,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(8),
//             image: selectedImage == null
//                 ? DecorationImage(
//               image: AssetImage('assets/error.jpg'),
//               fit: BoxFit.cover,
//             )
//                 : null,
//           ),
//           child: selectedImage == null
//               ? Center(
//               child:
//               Text('ছবি নির্বাচন করুন', style: TextStyle(color: Colors.black)))
//               : ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: SizedBox(
//               width: double.infinity,
//               height: 150,
//               child: Image.file(
//                 selectedImage!,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//         ),
//       ),
//       SizedBox(height: 20),
//       TextFormField(
//         controller: nameController,
//         decoration: InputDecoration(
//           labelText: 'নাম',
//           border: OutlineInputBorder(),
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'এখানে নাম লিখুন';
//           }
//           return null;
//         },
//       ),
//       SizedBox(height: 20),
//       TextFormField(
//         controller: phoneController,
//         keyboardType: TextInputType.phone,
//         decoration: InputDecoration(
//           labelText: 'ফোন নম্বর',
//           border: OutlineInputBorder(),
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'এখানে ফোন নম্বর লিখুন';
//           }
//           return null;
//         },
//       ),
//       SizedBox(height: 20),
//       TextFormField(
//         controller: transactionController,
//         keyboardType: TextInputType.number,
//         decoration: InputDecoration(
//           labelText: 'লেনদেনের পরিমাণ(টাকা)',
//           border: OutlineInputBorder(),
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'এখানে লেনদেনের পরিমাণ লিখুন';
//           }
//           if (double.tryParse(value) == null) {
//             return 'সঠিক পরিমাণ লিখুন';
//           }
//           return null;
//         },
//       ),
//       SizedBox(height: 30),
//       Center(
//         child: ElevatedButton(
//           onPressed: onSaveNewSupplier,
//           style: ElevatedButton.styleFrom(
//             padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
//             backgroundColor: Colors.green,
//           ),
//           child: Text(
//             'সেভ করুন',
//             style: TextStyle(fontSize: 18, color: Colors.white),
//           ),
//         ),
//       ),
//     ],
//   );
// }