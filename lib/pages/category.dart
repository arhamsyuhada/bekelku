import 'package:bekelku/models/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool isExpense = true;
  int type = 2;
  final AppDb db = AppDb();
  TextEditingController categoryNameController = TextEditingController();

  Future insert(String name, int type) async {
    DateTime now = DateTime.now();
    await db.into(db.categories).insertReturning(
          CategoriesCompanion.insert(
              name: name, type: type, createdAt: now, updatedAt: now),
        );
  }

  Future<List<Category>> getAllCategory(int type) async {
    return await db.getAllCategoryRepo(type);
  }

  Future update(int categoryId, String newName) async {
    return await db.updateCategoryRepo(categoryId, newName);
  }

  void openDialog(Category? category) {
    if (category != null) {
      categoryNameController.text = category.name;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Text(
                      (isExpense)
                          ? "Kategori Pengeluaran"
                          : "Kategori Pemasukan",
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        color: (isExpense) ? Colors.red : Colors.green,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: categoryNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Nama",
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (category == null) {
                            insert(
                                categoryNameController.text, isExpense ? 2 : 1);
                            FlutterToastr.show(
                              'Kategori berhasil dibuat',
                              context,
                              backgroundColor: Colors.green.shade300,
                              position: FlutterToastr.bottom,
                              duration: FlutterToastr.lengthLong,
                            );
                          } else {
                            update(category.id, categoryNameController.text);
                            FlutterToastr.show(
                              'Kategori berhasil di edit',
                              context,
                              backgroundColor: Colors.green.shade300,
                              position: FlutterToastr.bottom,
                              duration: FlutterToastr.lengthLong,
                            );
                          }

                          Navigator.of(context, rootNavigator: true)
                              .pop('dialog');
                          setState(() {
                            categoryNameController.clear();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.white),
                        child: const Text('Simpan'))
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          // Toggle Button
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 0, left: 16, right: 16, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Switch(
                    value: isExpense,
                    onChanged: (bool value) {
                      setState(() {
                        isExpense = value;
                        type = value ? 2 : 1;
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
                  IconButton(
                    onPressed: () {
                      openDialog(null);
                    },
                    icon: const Icon(CupertinoIcons.add),
                  ),
                ],
              ),
            ),

            // List Category
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
                                  leading: isExpense
                                      ? const Icon(
                                          Icons.arrow_upward,
                                          color: Colors.red,
                                        )
                                      : const Icon(
                                          Icons.arrow_downward,
                                          color: Colors.green,
                                        ),
                                  title: Text(
                                    snapshot.data![index].name,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          db.deleteCategoryRepo(
                                              snapshot.data![index].id);
                                          FlutterToastr.show(
                                            'Berhasil Menghapus Kategori',
                                            context,
                                            backgroundColor:
                                                Colors.red.shade300,
                                            position: FlutterToastr.bottom,
                                            duration: FlutterToastr.lengthLong,
                                          );
                                          setState(() {});
                                        },
                                        icon: const Icon(CupertinoIcons.delete),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          openDialog(snapshot.data![index]);
                                        },
                                        icon: const Icon(Icons.edit),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    } else {
                      return const Center(
                        child: Text('Tidak Ada Data Kategori'),
                      );
                    }
                  } else {
                    return const Center(
                      child: Text('Tidak Ada Data Kategori'),
                    );
                  }
                }
              },
            ),
            //List CATEGORY
          ],
        ),
      ),
    );
  }
}
