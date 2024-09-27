import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:task/fl_chart.dart';
import 'package:task/screen/signin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SigninScreen(), // Change to the sign-in screen
    );
  }
}

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  String _selectedType = 'รายรับ'; // Default is 'Income'
  final CollectionReference transactions =
      FirebaseFirestore.instance.collection('transactions');

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
    _selectedDate = DateTime.now();
  }

  // Function to add a new transaction (income or expense)
  Future<void> addTransaction(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("เพิ่มรายรับ/รายจ่าย"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "จำนวนเงิน"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: ['รายรับ', 'รายจ่าย'].map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "ประเภท"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "โน้ต"),
              ),
              const SizedBox(height: 10),

              // ปุ่มเลือกวันที่
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      "วันที่: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}"),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () async {
                  await transactions.add({
                    'amount': double.parse(_amountController.text),
                    'type': _selectedType,
                    'note': _noteController.text,
                    'date': Timestamp.fromDate(_selectedDate),
                    'uid': FirebaseAuth
                        .instance.currentUser!.uid, // บันทึกตามผู้ใช้
                  });
                  _amountController.clear();
                  _noteController.clear();
                  Navigator.pop(context);
                },
                child: const Text("บันทึก"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> logoutHandle(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SigninScreen()),
    );
  }

  double calculateTotal(List<QueryDocumentSnapshot> docs, String type) {
    return docs
        .where((doc) => doc['type'] == type)
        .fold(0.0, (previousValue, doc) => previousValue + doc['amount']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("บันทึกรายรับรายจ่าย"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await logoutHandle(context);
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: transactions
            .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final incomeTotal = calculateTotal(snapshot.data!.docs, 'รายรับ');
          final expenseTotal = calculateTotal(snapshot.data!.docs, 'รายจ่าย');
          final balance = incomeTotal - expenseTotal;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('ยอดรวม: ฿$balance',
                    style: const TextStyle(fontSize: 18)),
              ),
              // Display the chart here
              SizedBox(
                height: 300, // Adjust height as needed
                child: buildExpenseIncomeChart(snapshot.data!.docs),
              ),
              Expanded(
                child: ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final DateTime date = (doc['date'] as Timestamp).toDate();
                    return ListTile(
                      title: Text('${doc['type']} ฿${doc['amount']}'),
                      subtitle: Text(
                          '${doc['note']} - ${DateFormat('dd/MM/yyyy').format(date)}'),
                      trailing: Icon(
                        doc['type'] == 'รายรับ'
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color:
                            doc['type'] == 'รายรับ' ? Colors.green : Colors.red,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addTransaction(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
