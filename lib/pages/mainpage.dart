import 'package:bekelku/pages/category.dart';
import 'package:bekelku/pages/home.dart';
import 'package:bekelku/pages/transaction.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late DateTime selectedDate;
  late List<Widget> _children;
  late int currentIndex;

  @override
  void initState() {
    updateView(0, DateTime.now());
    super.initState();
  }

  void updateView(int index, DateTime? date) {
    setState(() {
      if (date != null) {
        selectedDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(date));
      }

      currentIndex = index;
      _children = [HomePage(selectedDate: selectedDate), const CategoryPage()];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (currentIndex == 0)
          ? CalendarAppBar(
              backButton: false,
              locale: 'id',
              accent: Colors.amber.shade700,
              onDateChanged: (value) {
                setState(() {
                  selectedDate = value;
                  updateView(0, selectedDate);
                });
              },
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now(),
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 25,
                  bottom: 10,
                  left: 25,
                ),
                child: Text(
                  'Kategori',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
      floatingActionButton: Visibility(
        visible: (currentIndex == 0) ? true : false,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => const TransactionPage(
                  transactionWithCategory: null,
                ),
              ),
            )
                .then((value) {
              setState(() {});
            });
          },
          backgroundColor: Colors.amber.shade700,
          shape: const CircleBorder(),
          child: const Icon(
            CupertinoIcons.add,
            color: Colors.white,
          ),
        ),
      ),
      body: _children[currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
              onPressed: () {
                updateView(0, DateTime.now());
              },
              icon: const Icon(CupertinoIcons.home)),
          const SizedBox(
            width: 20,
          ),
          IconButton(
              onPressed: () {
                updateView(1, null);
              },
              icon: const Icon(CupertinoIcons.list_bullet))
        ],
      )),
    );
  }
}
