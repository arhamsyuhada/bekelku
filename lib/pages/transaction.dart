import 'package:bekelku/models/database.dart';
import 'package:bekelku/models/transaction_category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  final TransactionWithCategory? transactionWithCategory;

  const TransactionPage({Key? key, required this.transactionWithCategory})
      : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final AppDb db = AppDb();
  bool isExpense = true;
  late int type;

  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  Category? selectedCategory;

  Future insert(
      int amount, DateTime date, String detail, int categoryId) async {
    DateTime now = DateTime.now();
    await db.into(db.transactions).insertReturning(TransactionsCompanion.insert(
        name: detail,
        categoryId: categoryId,
        transactionDate: date,
        amount: amount,
        createdAt: now,
        updatedAt: now));
  }

  Future<List<Category>> getAllCategory(int type) async {
    return await db.getAllCategoryRepo(type);
  }

  Future update(int transactionId, int amount, int categoryId,
      DateTime transactionDate, String detail) async {
    return await db.updateTransactionRepo(
        transactionId, amount, categoryId, transactionDate, detail);
  }

  @override
  void initState() {
    if (widget.transactionWithCategory != null) {
      updateTransactionView(widget.transactionWithCategory!);
    } else {
      type = 2;
    }
    super.initState();
  }

  void updateTransactionView(TransactionWithCategory transactionWithCategory) {
    amountController.text =
        transactionWithCategory.transaction.amount.toString();
    detailController.text = transactionWithCategory.transaction.name;
    dateController.text = DateFormat('yyyy-MM-dd')
        .format(transactionWithCategory.transaction.transactionDate);
    type = transactionWithCategory.category.type;
    (type == 2) ? isExpense = true : isExpense = false;
    selectedCategory = transactionWithCategory.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Switch(
                    value: isExpense,
                    onChanged: (bool value) {
                      setState(() {
                        isExpense = value;
                        type = (isExpense) ? 2 : 1;
                        selectedCategory = null;
                      });
                    },
                    inactiveTrackColor: Colors.green.shade200,
                    inactiveThumbColor: Colors.green,
                    activeColor: Colors.red,
                  ),
                  Text(
                    isExpense ? 'Pengeluaran' : 'Pemasukan',
                    style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: isExpense ? Colors.red : Colors.green),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Jumlah Uang",
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Kategori',
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              FutureBuilder<List<Category>>(
                  future: getAllCategory(type),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: DropdownButton<Category>(
                                value: (selectedCategory == null)
                                    ? snapshot.data!.first
                                    : selectedCategory,
                                isExpanded: true,
                                icon: const Icon(CupertinoIcons.chevron_down),
                                items: snapshot.data!.map((Category item) {
                                  return DropdownMenuItem<Category>(
                                    value: item,
                                    child: Text(item.name),
                                  );
                                }).toList(),
                                onChanged: (Category? value) {
                                  setState(() {
                                    selectedCategory = value;
                                  });
                                }),
                          );
                        } else {
                          return const Center(
                            child: Text('Tidak ada Kategori'),
                          );
                        }
                      } else {
                        return const Center(
                          child: Text('Tidak ada Kategori yang ditemukan'),
                        );
                      }
                    }
                  }),
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  readOnly: true,
                  controller: dateController,
                  decoration:
                      const InputDecoration(labelText: "Masukkan Tanggal"),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2022),
                        lastDate: DateTime(2030));

                    if (pickedDate != null) {
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);

                      dateController.text = formattedDate;
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: detailController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Catatan",
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      if (widget.transactionWithCategory == null) {
                        if (selectedCategory != null) {
                          await insert(
                            int.parse(amountController.text),
                            DateTime.parse(dateController.text),
                            detailController.text,
                            selectedCategory!.id,
                          );
                        } else {
                          FlutterToastr.show(
                            'Silakan isi semua kolom yang wajib diisi dan wajib pilih kategori',
                            context,
                            backgroundColor: Colors.red.shade300,
                            position: FlutterToastr.bottom,
                            duration: FlutterToastr.lengthLong,
                          );
                          return;
                        }
                      } else {
                        if (selectedCategory != null) {
                          await update(
                            widget.transactionWithCategory!.transaction.id,
                            int.parse(amountController.text),
                            selectedCategory!.id,
                            DateTime.parse(dateController.text),
                            detailController.text,
                          );
                        } else {
                          FlutterToastr.show(
                            'Silakan isi semua kolom yang wajib diisi',
                            context,
                            backgroundColor: Colors.red.shade300,
                            position: FlutterToastr.bottom,
                            duration: FlutterToastr.lengthLong,
                          );
                          return;
                        }
                      }

                      if (!context.mounted) return;

                      FlutterToastr.show(
                        'Transaksi ${widget.transactionWithCategory == null ? 'berhasil dibuat' : 'berhasil di edit'} ',
                        context,
                        backgroundColor: Colors.green.shade300,
                        position: FlutterToastr.bottom,
                        duration: FlutterToastr.lengthLong,
                      );

                      Navigator.popUntil(context, ModalRoute.withName('/'));
                    } catch (error) {
                      FlutterToastr.show(
                        '$error',
                        context,
                        backgroundColor: Colors.red.shade300,
                        position: FlutterToastr.bottom,
                        duration: FlutterToastr.lengthLong,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.white),
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
