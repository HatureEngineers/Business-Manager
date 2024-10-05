import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'customer/add_customer_page.dart'; // AddCustomerPage ইম্পোর্ট

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  TextEditingController searchController = TextEditingController();
  TextEditingController creditSaleAmountController = TextEditingController();
  TextEditingController quickSaleAmountController = TextEditingController();

  String selectedCustomerId = '';
  String selectedCustomerName = '';
  int customerTransaction = 0;

  // কাস্টমার খুঁজে পেতে ফায়ারবেস থেকে ডেটা ফেচ করা
  Future<void> fetchCustomerData(String customerId) async {
    DocumentSnapshot customerData = await FirebaseFirestore.instance.collection('customers').doc(customerId).get();
    if (customerData.exists) {
      setState(() {
        selectedCustomerName = customerData['name'];
        customerTransaction = customerData['transaction'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('বিক্রি পেজ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "বাকিতে বিক্রি" সেকশন
            Text(
              'বাকিতে বিক্রি',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('কাস্টমার যুক্ত করুনঃ'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    // AddCustomerPage পেজে যাওয়ার জন্য
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddCustomerPage()),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 10),

            // সার্চ ফিল্ড
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'কাস্টমার খুঁজুন',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) async {
                setState(() {
                  selectedCustomerId = value;
                });
                await fetchCustomerData(selectedCustomerId);
              },
            ),
            SizedBox(height: 10),

            // সিলেক্ট করা কাস্টমারের নাম এবং বাকির পরিমাণ দেখানো
            if (selectedCustomerName.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('নামঃ $selectedCustomerName'),
                  Text('বাকির পরিমাণঃ $customerTransaction'),
                ],
              ),
            SizedBox(height: 10),

            // নতুন বিক্রির এমাউন্ট ইনপুট ফিল্ড
            TextField(
              controller: creditSaleAmountController,
              decoration: InputDecoration(
                labelText: 'বিক্রির এমাউন্ট লিখুন',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),

            // "বিক্রি করুন" বাটন
            ElevatedButton(
              onPressed: () async {
                if (selectedCustomerId.isNotEmpty && creditSaleAmountController.text.isNotEmpty) {
                  int saleAmount = int.parse(creditSaleAmountController.text);

                  // কাস্টমারের transaction আপডেট
                  await FirebaseFirestore.instance.collection('customers').doc(selectedCustomerId).update({
                    'transaction': FieldValue.increment(saleAmount),
                  });

                  // Cashbox এ নতুন বিক্রি যুক্ত করা
                  await FirebaseFirestore.instance.collection('cashbox').add({
                    'amount': saleAmount,
                    'reason': 'বিক্রি',
                    'time': Timestamp.now(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('বিক্রি সম্পন্ন হয়েছে')),
                  );

                  setState(() {
                    searchController.clear();
                    creditSaleAmountController.clear();
                    selectedCustomerId = '';
                    selectedCustomerName = '';
                  });
                }
              },
              child: Text('বিক্রি করুন'),
            ),
            SizedBox(height: 20),

            // "দ্রুত বিক্রি" সেকশন
            Text(
              'দ্রুত বিক্রি',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // দ্রুত বিক্রির ইনপুট ফিল্ড
            TextField(
              controller: quickSaleAmountController,
              decoration: InputDecoration(
                labelText: 'বিক্রয়ের পরিমাণ লিখুন',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),

            // "বিক্রি করুন" বাটন
            ElevatedButton(
              onPressed: () async {
                if (quickSaleAmountController.text.isNotEmpty) {
                  int quickSaleAmount = int.parse(quickSaleAmountController.text);

                  // Sales এবং Cashbox এ নতুন বিক্রি যুক্ত করা
                  await FirebaseFirestore.instance.collection('sales').add({
                    'amount': quickSaleAmount,
                    'user_id': FirebaseAuth.instance.currentUser?.uid,
                    'time': Timestamp.now(),
                  });

                  await FirebaseFirestore.instance.collection('cashbox').add({
                    'amount': quickSaleAmount,
                    'reason': 'বিক্রি',
                    'time': Timestamp.now(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('দ্রুত বিক্রি সম্পন্ন হয়েছে')),
                  );

                  setState(() {
                    quickSaleAmountController.clear();
                  });
                }
              },
              child: Text('বিক্রি করুন'),
            ),
          ],
        ),
      ),
    );
  }
}
