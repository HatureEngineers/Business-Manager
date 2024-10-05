// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
//
// String? getCurrentUserId() {
//   return FirebaseAuth.instance.currentUser?.uid;
// }
//
// Future<void> saveNewSupplier({
//   required String name,
//   required String phone,
//   required double transaction,
//   required DateTime transactionDate,
//   File? imageFile,
// }) async {
//   String? uid = getCurrentUserId();
//   if (uid == null) {
//     throw Exception('User  is not logged in');
//   }
//
//   if (name.isEmpty || phone.isEmpty || transaction == 0) {
//     throw Exception('Invalid input parameters');
//   }
//
//   String imageUrl = 'assets/error.jpg'; // Default image if no image selected
//   if (imageFile != null) {
//     try {
//       final storageRef = FirebaseStorage.instance
//           .ref()
//           .child('supplier_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
//       await storageRef.putFile(imageFile);
//       imageUrl = await storageRef.getDownloadURL();
//     } catch (e) {
//       throw Exception('Failed to upload image: $e');
//     }
//   }
//
//   final supplierData = {
//     'name': name,
//     'phone': phone,
//     'image': imageUrl,
//     'transaction': transaction,
//     'transactionDate': transactionDate.toIso8601String(),
//     'userId': uid,
//   };
//
//   try {
//     await FirebaseFirestore.instance.collection('users').doc(uid).collection('suppliers').add(supplierData);
//   } catch (e) {
//     throw Exception('Failed to add supplier data: $e');
//   }
// }