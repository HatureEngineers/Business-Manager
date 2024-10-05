// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
//
// String? getCurrentUserId() {
//   User? user = FirebaseAuth.instance.currentUser;
//   return user?.uid;
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
//   if (uid != null) {
//     String imageUrl = 'assets/error.jpg'; // Default image if no image selected
//     if (imageFile != null) {
//       final storageRef = FirebaseStorage.instance
//           .ref()
//           .child('supplier_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
//       await storageRef.putFile(imageFile);
//       imageUrl = await storageRef.getDownloadURL();
//     }
//
//     final supplierData = {
//       'name': name,
//       'phone': phone,
//       'image': imageUrl,
//       'transaction': transaction,
//       'transactionDate': transactionDate.toIso8601String(),
//       'userId': uid,
//     };
//
//     await FirebaseFirestore.instance.collection('users').doc(uid).collection('suppliers').add(supplierData);
//   }
// }
