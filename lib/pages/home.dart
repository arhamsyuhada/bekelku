import 'package:bekelku/models/database.dart';
import 'package:bekelku/models/transaction_category.dart';
import 'package:bekelku/pages/transaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;

  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDb db = AppDb();

  @override
  void initState() {
    super.initState();
  }

  Future<int> getTotalTransactionAmount() async {
    final List<Transaction> transactions = await db.getAllTransactionsRepo();

    int totalAmount = 0;
    for (var transaction in transactions) {
      totalAmount += transaction.amount;
    }

    return totalAmount;
  }

  Future<void> deleteAllTransactions() async {
    await db.deleteAllTransactionsRepo();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // dashboard total income and expenses
            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FutureBuilder<int>(
                      future: getTotalTransactionAmount(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            int totalAmount = snapshot.data ?? 0;
                            // return Text('Total Transactions: $totalAmount');
                            return Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const SizedBox(
                                    width: 35,
                                    height: 35,
                                    child: Icon(
                                      CupertinoIcons.money_dollar,
                                      color: Colors.green,
                                      size: 35,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Jumlah Transaksi",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Rp $totalAmount',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Text Transactions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Transaksi',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            StreamBuilder<List<TransactionWithCategory>>(
                stream: db.getTransactionByDateRepo(widget.selectedDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.hasData) {
                      if (snapshot.data!.isNotEmpty) {
                        return ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 10,
                                  child: ListTile(
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon:
                                              const Icon(CupertinoIcons.delete),
                                          onPressed: () async {
                                            await db.deleteTransactionRepo(
                                                snapshot.data![index]
                                                    .transaction.id);

                                            setState(() {
                                              FlutterToastr.show(
                                                'Berhasil Menghapus Transaksi',
                                                context,
                                                backgroundColor:
                                                    Colors.red.shade300,
                                                position: FlutterToastr.bottom,
                                                duration:
                                                    FlutterToastr.lengthLong,
                                              );
                                            });
                                          },
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () async {
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TransactionPage(
                                                  transactionWithCategory:
                                                      snapshot.data![index],
                                                ),
                                              ),
                                            );
                                            setState(() {});
                                          },
                                        )
                                      ],
                                    ),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.data![index].category.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                            'Rp. ${snapshot.data![index].transaction.amount}'),
                                      ],
                                    ),
                                    subtitle: Text(
                                        snapshot.data![index].transaction.name),
                                    leading: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: (snapshot
                                                  .data![index].category.type ==
                                              2)
                                          ? const Icon(
                                              Icons.arrow_upward_rounded,
                                              color: Colors.red,
                                            )
                                          : const Icon(
                                              Icons.arrow_downward_rounded,
                                              color: Colors.green,
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            });
                      } else {
                        return const Center(
                          child: Text(' Tidak Ada Transaksi '),
                        );
                      }
                    } else {
                      return const Center(
                        child: Text('Tidak Ada Transaksi'),
                      );
                    }
                  }
                }),
          ],
        ),
      ),
    );
  }
}
